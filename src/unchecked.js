const parser = require("@solidity-parser/parser")
const { endianness } = require("os")
const { findContract, findFunc } = require("./tool")


let tmp = 100
const genSym = () => {
    return `__sent_result${tmp++}`
}

module.exports = {
    fixUnchecked(contractsAst, option) {
        const postFuncs = []
        parser.visit(contractsAst, {
            Block(ast) {
                const contract = findContract(ast, contractsAst)
                const func = findFunc(ast, contract)
                if (!func) return
                const funcName = func.name != "" ? func.name : "fallback"
                const config = option.configJson.UCR?.find(v => v.function_name === `${contract.name}::${funcName}`)
                if (!config) return
                const {strategys: [{repair_location: lines}]} = config
                lines.forEach(line => {
                    postFuncs.push(() => {
                        const stmts = ast.statements
                        const stmtIndex = stmts.findIndex(stmt => stmt.loc?.start.line <= line && stmt.loc?.end.line >= line)
                        if (stmtIndex < 0) return
                        
                        let right = stmts[stmtIndex].expression 
                        const retName = genSym()
                        if (stmts[stmtIndex].type == "ExpressionStatement"){
                            stmts[stmtIndex] = {
                                type: "VariableDeclarationStatement",
                                initialValue: right,
                                variables: [
                                    {
                                        type: "VariableDeclaration",
                                        identifier: {
                                            type: "Identifier", name: retName
                                        },
                                        name: retName,
                                        typeName: {
                                            type: "ElementaryTypeName", name: "bool"
                                        },
                                    }
                                ]
                            }

                            stmts.splice(stmtIndex + 1, 0, {
                                type: "ExpressionStatement",
                                expression: {
                                    type: "FunctionCall",
                                    arguments: [{
                                        type: "Identifier",
                                        name: retName
                                    }],
                                    expression: {
                                        type: "Identifier",
                                        name: "require"
                                    },
                                    names: []
                                }
                            })
                        } else if(stmts[stmtIndex].type == "VariableDeclarationStatement"){
                            let varName = null
                            stmts[stmtIndex].variables.forEach(variable =>{
                                if (variable.typeName.name == "bool"){
                                    varName = variable.name
                                }
                            })
                            if (!varName) return

                            stmts.splice(stmtIndex + 1, 0, {
                                type: "ExpressionStatement",
                                expression: {
                                    type: "FunctionCall",
                                    arguments: [{
                                        type: "Identifier",
                                        name: varName
                                    }],
                                    expression: {
                                        type: "Identifier",
                                        name: "require"
                                    },
                                    names: []
                                }
                            })
                        } else if(stmts[stmtIndex].type == "IfStatement"){
                            if (stmts[stmtIndex].trueBody.type == "ExpressionStatement"){
                                right = stmts[stmtIndex].trueBody.expression
                                stmts[stmtIndex].trueBody = {
                                    type: "Block",
                                    statements: [
                                        {
                                            type: "VariableDeclarationStatement",
                                            initialValue: right,
                                            variables: [
                                                {
                                                    type: "VariableDeclaration",
                                                    identifier: {
                                                        type: "Identifier", name: retName
                                                    },
                                                    name: retName,
                                                    typeName: {
                                                        type: "ElementaryTypeName", name: "bool"
                                                    },
                                                }
                                            ]
                                        },
                                        {
                                            type: "ExpressionStatement",
                                            expression: {
                                                type: "FunctionCall",
                                                arguments: [{
                                                    type: "Identifier",
                                                    name: retName
                                                }],
                                                expression: {
                                                    type: "Identifier",
                                                    name: "require"
                                                },
                                                names: []
                                            }
                                        }
                                    ]
                                }
                            }
                        }
                    })
                })
                
            }
        })
        postFuncs.forEach(f => f())
        return contractsAst
    }
}