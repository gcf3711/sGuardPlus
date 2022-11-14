const parser = require("@solidity-parser/parser")
const { findContract, findFunc } = require("./tool")


module.exports = {
    /*

        address private owner;
        constructor() internal {
                owner = msg.sender
        }
        加require(msg.sender == __owner)
    */
    fixSuicide: (contractsAst, option) => {
        if (!option.configJson.USI) return contractsAst
        option.configJson.USI.forEach(usi => {
            let [contractName, funcName] = usi.function_name.split("::")
            funcName = funcName == "fallback" ? "" : funcName
            const contract = contractsAst.children.find(v => v.name === contractName)
            const targetFunc = contract.subNodes.find(v => v.name === funcName)
            
            targetFunc.modifiers.push({
                arguments: null,
                name: "__onlyOwner",
                type: "ModifierInvocation"
            })

            contract.sguardPlusForSui = true
        })

        // const postFuncs = []
        // parser.visit(contractsAst, {
        //     ExpressionStatement(ast, parent) {
        //         if (!(ast.expression.type == "FunctionCall" && ["selfdestruct","suicide"].includes(ast.expression.expression.name))) return
        //         const contract = findContract(ast, contractsAst)
        //         const func = findFunc(ast, contract)
        //         const funcName = func.name != "" ? func.name : "fallback"
        //         if (!option.configJson.USI.find(v => v.function_name === `${contract.name}::${funcName}`)) return
        //         if (!contract || !func) return
        //         // const require = {
        //         //     type: "ExpressionStatement",
        //         //     expression: {
        //         //         type: "FunctionCall",
        //         //         arguments: [{
        //         //             type: "BinaryOperation",
        //         //             operator: "==",
        //         //             left: {
        //         //                 type: "MemberAccess",
        //         //                 memberName : "sender",
        //         //                 expression: {
        //         //                     type: "Identifier",
        //         //                     name: "msg"
        //         //                 }
        //         //             },
        //         //             right: {
        //         //                 type: "Identifier",
        //         //                 name: "__owner"
        //         //             }
        //         //         }],
        //         //         expression: {
        //         //             type: "Identifier",
        //         //             name: "require",
        //         //         },
        //         //         identifiers: [],
        //         //         names: [],
        //         //     }
        //         // }
        //         // postFuncs.push(() => {
        //         //     parent.statements.splice(
        //         //         parent.statements.indexOf(ast),
        //         //         0,
        //         //         require)
        //         // })
        //         contract.sguardPlusForSui = true

        //     }
        // })
        // postFuncs.forEach(f => f())
        return contractsAst
    }

}