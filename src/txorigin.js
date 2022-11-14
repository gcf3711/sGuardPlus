
const parser = require("@solidity-parser/parser")
const { findContract, findFunc } = require("./tool")

module.exports = {
    fixTxOrigin: (ast, option) => {
        if (!option.configJson.TXO) return ast

        const extractDep = (ast) => {
            const dep = {}
            const getMsgSender = ast => {
                const res = []
                parser.visit(ast, {
                    MemberAccess(ast) {
                        const {
                            expression,
                            memberName
                        } = ast
                        if (expression.type == "Identifier" &&
                            expression.name == "msg" &&
                            memberName == "sender"
                        ) {
                            res.push("msg.sender")
                        }
                    },

                    Identifier(ast) {
                        const key = ast.name
                        if (dep[key]) {
                            res.push(...dep[key])
                        }
                    }

                })
                return res
            }

            parser.visit(ast, {
                BinaryOperation(binAst, parent) {
                    const {
                        operator,
                        left,
                        right
                    } = binAst
                    if (operator == "=") {
                        dep[left.name] = getMsgSender(right)
                    }
                }
            })
            return dep
        }

        const existMsgSender = (ast, dep) => {
            let flag = false
            parser.visit(ast, {
                Identifier(ast) {
                    if (dep[ast.name]) {
                        flag = true
                    }
                },
                MemberAccess(ast) {
                    const {
                        expression,
                        memberName
                    } = ast
                    if (expression.type == "Identifier" &&
                        expression.name == "msg" &&
                        memberName == "sender"
                    ) {
                        flag = true
                    }
                }
            })
            return flag
        }

        const txOrigin2MsgSender = (ast, dep) => {
            parser.visit(ast, {
                MemberAccess(ast) {
                    const {
                        expression,
                        memberName
                    } = ast
                    if (expression.type == "Identifier" &&
                        expression.name == "tx" &&
                        memberName == "origin"
                    ) {
                        ast.expression.name = "msg"
                        ast.memberName = "sender"
                    }
                }
            })
        }

        
        parser.visit(ast, {
            FunctionDefinition(astFunc, parent) {
                if (!astFunc.body && !astFunc.modifiers) return
                const contract = findContract(astFunc, ast)
                const func = findFunc(astFunc, contract)
                if (!func) return
                const funcName = func.name != "" ? func.name : "fallback"
                const config = option.configJson.TXO?.find(v => v.function_name === `${contract.name}::${funcName}`)
                if (!config) return
                const {strategys: [{repair_location: lines}]} = config
                lines.forEach(line => {
                    if (astFunc.loc?.start.line <= line && astFunc.loc?.end.line >= line){
                        const stmts = astFunc.body.statements
                        const stmtIndex = stmts.findIndex(stmt => stmt.loc?.start.line <= line && stmt.loc?.end.line >= line)
                        if (stmtIndex < 0) return
                        txOrigin2MsgSender(stmts[stmtIndex], "")
                    } else {
                        parser.visit(ast, {
                            ModifierDefinition(astMod, parent) {
                                if (astMod.loc?.start.line <= line && astMod.loc?.end.line >= line){
                                    const stmts = astMod.body.statements
                                    const stmtIndex = stmts.findIndex(stmt => stmt.loc?.start.line <= line && stmt.loc?.end.line >= line)
                                    if (stmtIndex < 0) return
                                    txOrigin2MsgSender(stmts[stmtIndex], "")
                                }
                            }
                        })
                    }
                })
            }
        })
        // parser.visit(ast, {
        //     FunctionDefinition(ast, parent) {
        //         if (!ast.body) return
        //         const dep = extractDep(ast)

        //         parser.visit(ast, {
        //             BinaryOperation(ast, parent) {
        //                 if (!existMsgSender(ast.left, dep) && !existMsgSender(ast.right, dep)) {
        //                     txOrigin2MsgSender(ast, dep)
        //                 }
        //             }
        //         })

        //     },

        // })
        return ast
    }
}