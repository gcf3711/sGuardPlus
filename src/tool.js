

const include = (a, b) => {
    if (a.type == "ExpressionStatement") {
        a = a.expression
    }
    const {
        start: {line: astStart},
        end: {line: astEnd}
    } = a.loc
    const {
        start: {line: contractStart},
        end: {line: contractEnd}
    } = b.loc
    return astStart >= contractStart && astEnd <= contractEnd
}


const findContract = (ast, contractsAst) => {
    const contract = contractsAst.children.find(contract => {
        if (contract.type !== "ContractDefinition") return false
        return include(ast, contract)
    })
    return contract
}

const findFunc = (ast, contractAst) => {
    const func = contractAst.subNodes.find(funcAst => {
        if (funcAst.type !== "FunctionDefinition" && funcAst.type !== "ModifierDefinition") return false
        return include(ast, funcAst)
    })
    return func
}

module.exports = {
        findContract,
        findFunc
}