from slither.detectors.abstract_detector import AbstractDetector, DetectorClassification
from slither.utils.colors import blue, green, magenta, red
from slither.printers.abstract_printer import AbstractPrinter
from slither.core.declarations.function_contract import FunctionContract

class Scan(AbstractPrinter):
    ARGUMENT = 'cross-function-reentrancy'
    HELP = 'Printe cross-function-reentrancy of Smart Contract'
    IMPACT = DetectorClassification.INFORMATIONAL
    CONFIDENCE = DetectorClassification.HIGH

    WIKI = 'https://github.com/trailofbits/slither/wiki/Printer-documentation#evm'
    WIKI_TITLE = 'Model Prediction'
    WIKI_DESCRIPTION = 'This detector is based on trained machine learning models'
    WIKI_RECOMMENDATION = 'Avoid low-level calls. Check the call success. If the call is meant for a contract, check for code existence.'



    def __init__(self, slither, logger):
        super(Scan, self).__init__(slither, logger)

    def output(self, _filename):
        # start = time.clock()
        """ Print the vector of function of smart contract
        """
        if not self.slither.crytic_compile:
            txt = 'The EVM printer requires to compile with crytic-compile'
            self.info(red(txt))
            res = self.generate_output(txt)
            return res
        has_call_function=list()
        results=dict()
        for contract in self.slither.contracts:
            for function in contract.functions_declared:
                if [c for c in function.low_level_calls if c[1] == "call"]:
                    has_call_function.append(function.name)
        for contract in self.slither.contracts:
            for function in contract.functions_declared:
                if function.name in has_call_function:
                    res=self.findCall(function,has_call_function)
                    if res:
                        results[function.name]=res
        print(results)
        res = self.generate_output("")
        return res

    def findCall(self,_function,_has_call_function):
        if _function.internal_calls:
            for call in _function.internal_calls:
                if isinstance(call,FunctionContract):
                    if call.name in _has_call_function:
                        return call.name
                    else:
                        return self.findCall(call,_has_call_function)
        else:
            return ""

