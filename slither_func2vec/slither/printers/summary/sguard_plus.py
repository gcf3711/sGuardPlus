from slither.detectors.abstract_detector import AbstractDetector, DetectorClassification
from slither.analyses.evm import generate_source_to_evm_ins_mapping, load_evm_cfg_builder
from func_timeout import func_set_timeout
from slither.utils.colors import blue, green, magenta, red
from slither.printers.abstract_printer import AbstractPrinter
from slither.analyses.data_dependency.data_dependency import is_tainted, is_dependent
import os
from gensim.models.word2vec import Word2Vec
import numpy as np
import pandas as pd
import gdown
import tempfile
import csv,json
from slither.core.variables.state_variable import StateVariable
from slither.core.declarations.solidity_variables import SolidityVariableComposed
from slither.core.declarations import Function
from slither.slithir.operations import (
    HighLevelCall,
    LowLevelCall,
    Send,
    SolidityCall,
    Transfer,
    InternalCall,
    Return,
    EventCall,
)
from slither.core.cfg.node import NodeType
import joblib

class SguardPlus(AbstractPrinter):
    ARGUMENT = 'sguard_plus'
    HELP = 'Detect Vulnerabilities of Smart Contract via ML'
    IMPACT = DetectorClassification.INFORMATIONAL
    CONFIDENCE = DetectorClassification.HIGH

    WIKI = 'https://github.com/trailofbits/slither/wiki/Printer-documentation#evm'
    WIKI_TITLE = 'Model Prediction'
    WIKI_DESCRIPTION = 'This detector is based on trained machine learning models'
    WIKI_RECOMMENDATION = 'Avoid low-level calls. Check the call success. If the call is meant for a contract, check for code existence.'



    def __init__(self, slither, logger):
        super(SguardPlus, self).__init__(slither, logger)

    def output(self, _filename):
        # start = time.clock()
        """ Print the vector of function of smart contract
        """
        if not self.slither.crytic_compile:
            txt = 'The EVM printer requires to compile with crytic-compile'
            self.info(red(txt))
            res = self.generate_output(txt)
            return res

        filename_absolute = self.slither.contracts[0].source_mapping['filename_absolute']
        contract_file = self.slither.source_code[filename_absolute].encode('utf-8')
        contract_file_lines = open(filename_absolute, 'r',encoding='utf-8').readlines()
        features_name = [
            "protect_RT"
            , "has_arithmetic_op"
            , "protect_TO"
            , "protect_UCCRV"
            , "protect_UPS"
            , "has_high_level_call"
            , "has_low_level_call"
            , "has_callvalue"
            , "has_transfer"
            , "has_send"
            , "has_internal_call"
            , "is_visible"
            , "has_condition"
            , "has_modifier"
            , "msgsender"
            , "msgvalue"
        ]

        evm_info = self._extract_evm_info(self.slither)
        # word to vector model
        W2C_MODEL = WordVectorizer()

        vec_list = list()
        for contract in self.slither.contracts:
            if (contract.kind != "contract"):continue
            for function in contract.functions_declared:
                # print(f"origin : contract.name={contract.name}\nfunction.name={function.name}\n")
                function_name = function.name
                if function_name in ['slitherConstructorConstantVariables','slitherConstructorVariables']:
                    continue  # skip repeated constructor function
                try:
                    if function_name in ['constructor', contract.name]:
                        contract_cfg = evm_info['cfg_init', contract.name]
                        contract_pcs = evm_info['mapping_init', contract.name]
                    else:
                        contract_cfg = evm_info['cfg', contract.name]
                        contract_pcs = evm_info['mapping', contract.name]
                except:
                    # print("evm_info error")
                    continue
                f_nodes_mod_before = list()
                f_nodes_mod_after = list()
                for md in function.modifiers:
                    md_nodes = md.nodes
                    index_placeholder = -1
                    for idx,node in enumerate(md_nodes):
                        if node.type == NodeType.PLACEHOLDER:index_placeholder=idx
                    if index_placeholder != -1: # must have placeholder
                        f_nodes_mod_before += md_nodes[1:index_placeholder]  # skip modifier ENTRY_POINT node
                        if index_placeholder+1 < len(md_nodes):
                            f_nodes_mod_after += md_nodes[index_placeholder+1:]
                function_nodes=list()
                for node in function.nodes:
                    internalcall_function = ""
                    for ir in node.irs:
                        if ir.function.name!=function.name and not isinstance(ir,(SolidityCall,HighLevelCall)):
                            if isinstance(ir,InternalCall) and ir.function in contract.functions_declared:
                                internalcall_function = ir.function
                            else:
                                node.irs.remove(ir)
                    function_nodes.append(node)
                    if internalcall_function:
                        function_nodes.extend(internalcall_function.nodes)

                f_nodes_all = function_nodes[:1]+f_nodes_mod_before+function_nodes[1:]+f_nodes_mod_after

                ins_list = list()
                for node in f_nodes_all:
                    node_source_line = contract_file[0:node.source_mapping['start']].count("\n".encode("utf-8")) + 1
                    node_pcs = contract_pcs.get(node_source_line, [])

                    for pc in node_pcs:
                        ins = contract_cfg.get_instruction_at(pc).name.encode('utf-8').decode('utf-8-sig')
                        if len(ins.split(' ')) == 2:
                            ins = ins.split(' ')[0]
                        ins_list.append(ins)
                if not ins_list:
                    # print(f"not ins : \nfunction.name={function.name}\nfunction.canonical_name={function.canonical_name}")
                    continue

                other_feature = dict()
                for fn in features_name:
                    other_feature[fn]=0

                if function.visibility in ["public", "external"]:
                    other_feature["is_visible"] = 1
                if function.modifiers:
                    other_feature["has_modifier"] = 1

                for node in f_nodes_all:
                    if node.contains_if() or node.contains_require_or_assert():
                        other_feature["has_condition"] = 1
                    if any(v.name == "msg.sender" for v in node.solidity_variables_read):
                        other_feature["msgsender"] = 1
                    if any(v.name == "msg.value" for v in node.solidity_variables_read):
                        other_feature["msgvalue"] = 1
                    for ir in node.irs:
                        if isinstance(ir,HighLevelCall):
                            other_feature["has_high_level_call"] = 1
                        if isinstance(ir,LowLevelCall):
                            other_feature["has_low_level_call"] = 1
                            if ir.function_name=="call":
                                other_feature["has_callvalue"] = 1
                        if isinstance(ir, Transfer):
                            other_feature["has_transfer"] = 1
                        if isinstance(ir,Send):
                            other_feature["has_send"] = 1
                        if isinstance(ir,InternalCall):
                            other_feature["has_internal_call"] = 1

                if function.high_level_calls:
                    other_feature["has_high_level_call"] = 1

                if [c for c in function.low_level_calls if c[1] == "call"]:# call.value
                    other_feature["has_callvalue"]=1
                if other_feature["has_high_level_call"] or other_feature["has_low_level_call"] \
                        or other_feature["has_send"] or other_feature["has_transfer"]:
                    if not self.detect_reentrancy_protected(contract,function,f_nodes_all) and self.detect_reentrancy(contract,function,f_nodes_all):
                        other_feature["protect_RT"] = 1
                if self.detect_arithmetic_op(function,contract_file_lines):
                    other_feature["has_arithmetic_op"]=1
                if self.detect_txorigin(contract,function,f_nodes_all):
                    other_feature["protect_TO"] = 1
                if other_feature["has_low_level_call"] or other_feature["has_send"] or other_feature["has_high_level_call"]:
                    if self.detect_unused_return_values(contract,function,f_nodes_all):
                        other_feature["protect_UCCRV"] = 1
                        # print(function_name)
                if self.detect_unprotected_suicide(contract,function,f_nodes_all):
                    other_feature["protect_UPS"] = 1

                ins_vec = W2C_MODEL.vectorize(self.concatenate_list(self.replace_ins(ins_list)))
                func_vector = ins_vec.tolist()[0]
                info_list = [contract.name,function_name]
                vec_list.append(info_list+func_vector+self.add_feature(ins_list)+list(other_feature.values()))


        if vec_list:
            self.save_report(filename_absolute,vec_list)
            # for i in vec_list:
            #     print(i)
        res = self.generate_output("")
        # end = time.clock()
        # print("final is in ", end - start)
        return res

    def save_report(self,filename_absolute,vec_list):
        features = [ "1"
            , "2"
            , "3"
            , "4"
            , "5"
            , "6"
            , "7"
            , "8"
            , "9"
            , "10"
            , "11"
            , "12"
            , "13"
            , "14"
            , "15"
            , "16"
            , "17"
            , "18"
            , "19"
            , "20"
            , "CALL"
            , "ORIGIN"
            , "SELFDESTRUCT"
            , "protect_RT"
            , "has_arithmetic_op"
            , "protect_TO"
            , "protect_UCCRV"
            , "protect_UPS"
            , "has_high_level_call"
            , "has_low_level_call"
            , "has_callvalue"
            , "has_transfer"
            , "has_send"
            , "has_internal_call"
                    # , "has_write_after_call"
            , "is_visible"
            , "has_condition"
            , "has_modifier"
            , "msgsender"
            , "msgvalue"
        ]
        features_type = { "1": float
            , "2": float
            , "3": float
            , "4": float
            , "5": float
            , "6": float
            , "7": float
            , "8": float
            , "9": float
            , "10": float
            , "11": float
            , "12": float
            , "13": float
            , "14": float
            , "15": float
            , "16": float
            , "17": float
            , "18": float
            , "19": float
            , "20": float
            , "CALL": int
            , "ORIGIN": int
            , "SELFDESTRUCT": int
            , "protect_RT": int
            , "has_arithmetic_op": int
            , "protect_TO": int
            , "protect_UCCRV": int
            , "protect_UPS": int
            , "has_high_level_call": int
            , "has_low_level_call": int
            , "has_callvalue": int
            , "has_transfer": int
            , "has_send": int
            , "has_internal_call": int
                         # , "has_write_after_call": int
            , "is_visible": int
            , "has_condition": int
            , "has_modifier": int
            , "msgsender": int
            , "msgvalue": int
            }

        vul = ["REN","IOU","TXO","UCR","USI"]
        report = dict()
        for i in range(5):
            report[vul[i]]=list()
        # vulnerability = {"function_name":"","strategys":dict()}
        # strategy = {"type":"","repair_location":list()}
        f_path = os.path.dirname(os.path.realpath(__file__))
        models = [joblib.load(os.path.join(f_path,"models",f"{i+1}_xgbt_clf.pkl")) for i in range(5)]

        for v in vec_list:
            for i in range(5):
                vector = pd.DataFrame([v[2:]], columns=features).astype(features_type)
                if models[i].predict(vector)==[1]:
                    report[vul[i]].append({"function_name":f"{v[0]}::{v[1]}","strategys":list()})

        for contract in self.slither.contracts:
            for function in contract.functions_declared:
                for v in report[vul[0]]:#REN
                    if v["function_name"]==f"{contract.name}::{function.name}":
                        v["strategys"].append({"type":"modifier","repair_location":list()})
                        read_condition = list()
                        call_node = [i for i,n in enumerate(function.nodes) for ir in n.irs if isinstance(ir,LowLevelCall)]
                        if call_node:
                            for node in function.nodes[:call_node[-1]]:
                                if node.contains_require_or_assert() or node.contains_if():
                                    for ir in node.irs:
                                        read_condition.extend([v.name for v in ir.read if isinstance(v,StateVariable)])
                            for node in function.nodes[call_node[-1]:]:
                                branch_id = [n.node_id for n in function.nodes[call_node[-1]].dominance_frontier if n.type.name=="ENDIF"]
                                if [n for n in node.dominance_frontier if n.type.name=="ENDIF" and n.node_id not in branch_id ] : continue
                                if [w for w in node.state_variables_written if w.name in read_condition]:
                                    c_loc = function.nodes[call_node[-1]].source_mapping["lines"][0]
                                    w_loc = node.source_mapping["lines"][0]
                                    if c_loc<w_loc:
                                        v["strategys"].insert(0,{"type":"move","repair_location":[c_loc,w_loc]})
                                        break
                for v in report[vul[1]]:#IOU
                    pass
                for v in report[vul[2]]:#TXO
                    if v["function_name"]==f"{contract.name}::{function.name}":
                        v["strategys"].append({"type":"replace","repair_location":list()})
                        for md in function.modifiers:
                            for node in md.nodes:
                                if node.contains_require_or_assert() or node.contains_if():
                                    reads = [r for ir in node.irs for r in ir.read]
                                    if any((v.name == "tx.origin") for v in reads) and not any((v.name == "msg.sender") for v in reads):
                                        v["strategys"][0]["repair_location"].append(node.source_mapping["lines"][0])
                        for node in function.nodes:
                            if node.contains_require_or_assert() or node.contains_if():
                                reads = [r for ir in node.irs for r in ir.read]
                                if any((v.name == "tx.origin") for v in reads) and not any((v.name == "msg.sender"or is_dependent(v,SolidityVariableComposed('msg.sender'),function)) for v in reads):
                                    v["strategys"][0]["repair_location"].append(node.source_mapping["lines"][0])
                for v in report[vul[3]]:#UCR
                    if v["function_name"]==f"{contract.name}::{function.name}":
                        v["strategys"].append({"type":"check","repair_location":list()})
                        all_nodes = list()
                        for md in function.modifiers:
                            all_nodes.extend(md.nodes)
                        all_nodes.extend(function.nodes)
                        values_returned = []
                        vul_nodes = dict()
                        for n in all_nodes:
                            for ir in n.irs:
                                if isinstance(ir, (Send, LowLevelCall)) or (isinstance(ir, HighLevelCall) and isinstance(ir.function, Function) and
                    ['bool'] == ir.function.signature[-1]
                    #ir.function.solidity_signature in ["transfer(address,uint256)", "transferFrom(address,address,uint256)","mint(address,uint256)"]
                    ):
                                    if ir.lvalue and not isinstance(ir.lvalue, StateVariable):
                                        values_returned.append(ir.lvalue)
                                        vul_nodes[ir.lvalue]=n
                            if values_returned:
                                if n.contains_require_or_assert() or n.contains_if() or isinstance(ir, (Return, EventCall)):
                                    for ir in n.irs:
                                        for read in ir.read:
                                            if read in values_returned:
                                                values_returned.remove(read)
                                            else:
                                                for vr in values_returned:
                                                    if is_dependent(read, vr, function):
                                                        values_returned.remove(vr)
                        if values_returned:
                            for r in values_returned:
                                v["strategys"][0]["repair_location"].append(vul_nodes[r].source_mapping["lines"][0])
                for v in report[vul[4]]:#USI
                    pass



        f_name = "{0}_vul_report.json".format(os.path.basename(filename_absolute))
        f_path = os.path.join(os.path.dirname(filename_absolute), f_name)
        with open(f_path, 'w') as json_file:
            json.dump(report, json_file)


    def save_vec(self, filename_absolute, vec_list):
        f_name = "{0}.csv".format(os.path.basename(filename_absolute))
        f_path = os.path.join(os.path.dirname(filename_absolute), f_name)
        # print(f_path)
        f_csv = open(f_path, 'w', encoding='utf-8', newline="")
        csv_writer = csv.writer(f_csv)
        for v in vec_list:
            csv_writer.writerow(v)
        f_csv.close()

    def detect_reentrancy_protected(self,c,f,all_nodes):
        read_condition = list()
        for node in all_nodes:
            for ir in node.irs:
                if not isinstance(ir,(LowLevelCall,HighLevelCall,Transfer,Send)):
                    if node.contains_require_or_assert() or node.contains_if() :
                        for v in ir.read:
                            if isinstance(v,StateVariable):
                                read_condition.append(v.name)
                    else:
                        for w in node.state_variables_written:
                            if w.name in read_condition:
                                return True
                else:
                    return False
        return False

    def detect_reentrancy(self,c,f,all_nodes):
        has_call = -1
        for node in all_nodes:
            if has_call == -1:
                for ir in node.irs:
                    if isinstance(ir, (LowLevelCall, HighLevelCall, Transfer, Send)):
                        has_call = node.source_mapping["start"]
            else:
                if node.state_variables_written and node.source_mapping["start"]>has_call:
                    return True
        return False

    def detect_arithmetic_op(self,f,contract_file_lines):
        operators = ['--', '-=', '-', '++', '+=', '+', '*', '*=', r'/', r'/=', '**']
        func_lines = list(f.source_mapping['lines'])
        # print(contract.name+"."+function_name)
        for l in func_lines:
            line = str(contract_file_lines[l - 1]).split(r"//")[0]
            for op in operators:
                if op in line:
                    # print(f"*******{f.name}")
                    return True
        return False

    def detect_txorigin(self,c,f,all_nodes):
        for node in all_nodes:
            if node.contains_require_or_assert() or node.contains_if():
                txorigin = False
                msgsender = False
                for ir in node.irs:
                    reads = ir.read
                    for v in reads:
                        if any(
                            (v.name == "tx.origin" or is_dependent(v,SolidityVariableComposed('tx.origin'),f)) for v in reads
                        ):
                            txorigin = True
                        if any(
                            (v.name == "msg.sender" or is_dependent(v,SolidityVariableComposed('msg.sender'),f)) for v in reads
                        ):
                            msgsender = True
                if txorigin and not msgsender:
                    return True
        return False

    def detect_unused_return_values(self,c,f,all_nodes):
        values_returned = []
        for n in all_nodes:
            for ir in n.irs:
                if isinstance(ir, (Send,LowLevelCall)) or (isinstance(ir, HighLevelCall)
            and isinstance(ir.function, Function)
            and
                    ['bool'] == ir.function.signature[-1]
                    #ir.function.solidity_signature in ["transfer(address,uint256)", "transferFrom(address,address,uint256)","mint(address,uint256)"]
                    ):
                    # if a return value is stored in a state variable, it's ok
                    if ir.lvalue and not isinstance(ir.lvalue, StateVariable):
                        values_returned.append(ir.lvalue)
            if values_returned:
                if n.contains_require_or_assert() or n.contains_if() or isinstance(ir,(Return,EventCall)):
                    for ir in n.irs:
                        for read in ir.read:
                            if read in values_returned:
                                values_returned.remove(read)
                            else:
                                for v in values_returned:
                                    if is_dependent(read,v,c):
                                        values_returned.remove(v)
        if values_returned:
            return True
        return False

    def detect_unprotected_suicide(self,c,f,all_nodes):
        if f.name == "constructor":
            return False

        calls = [c.name for c in f.internal_calls]
        if not ("suicide(address)" in calls or "selfdestruct(address)" in calls):
            return False

        if f.visibility not in ["public", "external"]:
            return False

        has_condition = False
        if ['onlymanyowners'] == [m.name for m in f.modifiers]:
            for node in all_nodes:
                if node.contains_require_or_assert() or node.contains_if() :
                    if any(v.name == "msg.sender" for v in node.solidity_variables_read):
                        has_condition = True
            return not has_condition

        has_condition = False
        for node in all_nodes:
            if node.contains_require_or_assert() or node.contains_if() :
                has_condition = True
            for ir in node.irs:
                if isinstance(ir,(SolidityCall)) and ir.function.name in ['selfdestruct(address)','suicide(address)']:
                    return not has_condition
        return False



    def concatenate_list(self, str_list):
        result = ""
        for x in str_list:
            result += str(x)
            result += " "
        return result

    def add_feature(self, ins_list):
        feature_list = []
        # has critical opcodes
        ins_key = ['CALL', 'ORIGIN', 'SELFDESTRUCT']
        for ins in ins_key:
            if ins in ins_list:
                feature_list.append(1)
            else:
                feature_list.append(0)

        return feature_list

    def replace_ins(self, ins_list):
        push = ['PUSH1', 'PUSH2', 'PUSH3', 'PUSH4', 'PUSH5', 'PUSH6', 'PUSH7', 'PUSH8', 'PUSH9', 'PUSH10', 'PUSH11',
                'PUSH12', 'PUSH13', 'PUSH14', 'PUSH15', 'PUSH16', 'PUSH17', 'PUSH18', 'PUSH19', 'PUSH20', 'PUSH21',
                'PUSH22', 'PUSH23', 'PUSH24', 'PUSH25', 'PUSH26', 'PUSH27', 'PUSH28', 'PUSH29', 'PUSH30', 'PUSH31',
                'PUSH32']
        swap = ['SWAP1', 'SWAP2', 'SWAP3', 'SWAP4', 'SWAP5', 'SWAP6', 'SWAP7', 'SWAP8', 'SWAP9', 'SWAP10', 'SWAP11',
                'SWAP12', 'SWAP13', 'SWAP14', 'SWAP15', 'SWAP16']
        dup = ['DUP1', 'DUP2', 'DUP3', 'DUP4', 'DUP5', 'DUP6', 'DUP7', 'DUP8', 'DUP9', 'DUP10', 'DUP11', 'DUP12',
               'DUP13', 'DUP14', 'DUP15', 'DUP16']
        log = ['LOG0', 'LOG1', 'LOG2', 'LOG3', 'LOG4']
        for i, char in enumerate(ins_list):
            if char in push:
                ins_list[i] = 'PUSH'
            elif char in swap:
                ins_list[i] = 'SWAP'
            elif char in dup:
                ins_list[i] = 'DUP'
            elif char in log:
                ins_list[i] = 'LOG'
        return ins_list

    # @timeout_decorator.timeout(20, use_signals=False)
    @func_set_timeout(20)
    def _get_CFG(self, CFG, bytecode):
        return CFG(bytecode)


    def _extract_evm_info(self,slither):
        """
        Extract evm information for all derived contracts using evm_cfg_builder

        Returns: evm CFG and Solidity source to Program Counter (pc) mapping
        """

        evm_info = {}

        CFG = load_evm_cfg_builder()

        for contract in slither.contracts:
            # print(contract.name)
            contract_bytecode_runtime = (
                contract.compilation_unit.crytic_compile_compilation_unit.bytecode_runtime(
                    contract.name
                )
            )
            contract_srcmap_runtime = (
                contract.compilation_unit.crytic_compile_compilation_unit.srcmap_runtime(contract.name)
            )
            if contract_bytecode_runtime == "" : continue
            # print(contract.name)
            # print(contract_srcmap_runtime)

            cfg = CFG(contract_bytecode_runtime)#  Consuming too much time TODO
            evm_info["cfg", contract.name] = cfg
            evm_info["mapping", contract.name] = generate_source_to_evm_ins_mapping(
                cfg.instructions,
                contract_srcmap_runtime,
                slither,
                contract.source_mapping["filename_absolute"],
            )
            contract_bytecode_init = (
                contract.compilation_unit.crytic_compile_compilation_unit.bytecode_init(contract.name)
            )
            contract_srcmap_init = (
                contract.compilation_unit.crytic_compile_compilation_unit.srcmap_init(contract.name)
            )
            cfg_init = CFG(contract_bytecode_init)

            evm_info["cfg_init", contract.name] = cfg_init
            evm_info["mapping_init", contract.name] = generate_source_to_evm_ins_mapping(
                cfg_init.instructions,
                contract_srcmap_init,
                slither,
                contract.source_mapping["filename_absolute"],
            )

        return evm_info


class WordVectorizer(object):
    def __init__(self):
        self._wver = self._load_trained_model()

    def _load_trained_model(self):
        url = "https://drive.google.com/uc?id=1P1VrXIMx5Iglm0ek4qcnGuMicxcALaa-"
        temp_path = tempfile.gettempdir()
        if not os.path.exists(os.path.join(temp_path, 'word2vec.model')):
            gdown.download(url, os.path.join(temp_path, 'word2vec.model'), quiet=True)
        # if not os.path.exists(abs_path):
        #     # TODO: throw error
        #     raise ValueError("word2vec model not found")
        return Word2Vec.load(os.path.join(temp_path, "word2vec.model"))

    def vectorize(self, dataset):
        return self._replace_op_with_vec(dataset, self._wver)

    def _featurize_w2v(self, model, sentences):
        f = np.zeros((len(sentences), model.vector_size))
        for i, s in enumerate(sentences):
            for w in s:
                try:
                    vec = model.wv[w]
                except KeyError:
                    continue
                f[i, :] = f[i, :] + vec
            f[i, :] = f[i, :] / len(s)
        return f

    def _replace_op_with_vec(self, op_seq, model):
        inter_train_data_list = []
        inter_train_data_list.append(op_seq.split(' '))
        inter_train_data_list[0] = inter_train_data_list[0][:-1] #delete ' ' in the list end
        inter_feature = self._featurize_w2v(model, inter_train_data_list)
        return inter_feature

