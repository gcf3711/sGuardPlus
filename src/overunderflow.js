const parser = require("@solidity-parser/parser")
const { parse } = require("path")
const { Template } = require("./template")
const {findContract, findFunc} = require("./tool")


const tmpVar = "___tmp"
let i = 100
const genSym = () => {
    return tmpVar + (i++)
}



const getType = (ast, contractsAst) => {
    let typ = null
    if (ast.type == "IndexAccess") {
        getIndexType(ast, contractsAst, t => typ = t)
        // console.log(ast, contractsAst)
        if (!typ) return null
        if (typ.type == "Mapping") {
            return typ.valueType.name
        } else {
            return typ.name
        }
    } else if (ast.type == "Identifier") {
        const targetSymName = ast.name
        const contract = findContract(ast, contractsAst)
        // find local variable first
        const funcDef = findFunc(ast, contract)
        parser.visit(funcDef, {
            VariableDeclarationStatement(ast) {
                const variable = ast.variables[0]
                if (variable.name !== targetSymName) return
                typ = variable.typeName.name
            }
        })

        parser.visit(funcDef, {
            VariableDeclaration(ast) {
                const variable = ast
                if (variable.name !== targetSymName) return
                typ = variable.typeName.name
            }
        })

        if (typ) return typ

        //then find state variable next
        contract.subNodes.forEach(subNode => {
            if (subNode.type == "StateVariableDeclaration"){ 
                const variable = subNode.variables[0]
                if (variable.name !== targetSymName) return
                typ = variable.typeName.name
            }
        })

        // find variable of all contracts
        if (!typ){
            parser.visit(contractsAst, {
                StateVariableDeclaration(node) {
                    const variable = node.variables[0]
                    if (variable.name !== targetSymName) return
                    typ = variable.typeName.name
                }
            })
        }

        if (!typ) console.error(`error can not find type for ${JSON.stringify(ast)}`)
        
        return typ

    } else if (ast.type == "FunctionCall") {
        if (String(ast.expression.typeName.name).includes("int")){
            return ast.expression.typeName.name
        }else{
            console.log(ast)
        }
    } else if (ast.type == "BinaryOperation") {
        const t1 = getType(ast.left, contractsAst)
        const t2 = getType(ast.right, contractsAst)
        return t1 ? t1 : t2
    } else if (ast.type == "NumberLiteral"){
        typ = "uint256"
        return typ
    } else if (ast.type == "MemberAccess" && ["value","length"].includes(ast.memberName) ){
        typ = "uint256"
        return typ
    } else if (ast.type == "TupleExpression"){
        ast.components.forEach(comAst => {
            typ = getType(comAst, contractsAst)
            if(typ) return
        })
        return typ
    }
}

const getIndexType = (ast, contractsAst, getType = () => {}) => {
    if (ast.type != "IndexAccess") return null
    if (ast.base.type != "Identifier") return null //第二层
    const targetSymName = ast.base.name
    const contract = findContract(ast, contractsAst)

    let typ = null

    // find local variable first
    const funcDef = findFunc(ast, contract)
    parser.visit(funcDef, {
        VariableDeclarationStatement(ast) {
            const variable = ast.variables[0]
            if (variable.name !== targetSymName) return
            getType(variable.typeName)
            typ = variable.typeName.keyType
        }
    })

    if (typ) return typ

    // then find state variable next
    contract.subNodes.forEach(subNode => {
        if (subNode.type !== "StateVariableDeclaration") return
        const variable = subNode.variables[0]
        if (variable.name !== targetSymName) return
        getType(variable.typeName)
        typ = variable.typeName.keyType
    })

    if (!typ) console.error(`error can not find type for ${JSON.stringify(ast)}`)
    
    return typ
}

const elimateSideEffect = (ast, contractsAst) => {
    if (ast.type !== "IndexAccess") return null
    // const indexType = getIndexType(ast, contractsAst)
    // if (!indexType) return null

    const sym = genSym()
    const assign = {
        type: "VariableDeclarationStatement",
        variables: [{
            expression: null,
            identifier: {
                type: "Identifier",
                name: sym
            },
            isIndexed: false,
            isStateVar: false,
            name: sym,
            storageLocation: null,
            type: "VariableDeclaration",
            typeName: {
                type: "ElementaryTypeName",
                name: "uint",
              }
        }],
        initialValue: ast.index
    }
    ast.index = {
        type: "Identifier",
        name: sym
    }
    return assign
}


const isAssignment = ast => {
    const op = [
        "+=",
        "-=",
        "*=",
        "/="
    ]
    
    return ast.type == "BinaryOperation" && op.find(v => v == ast.operator)
}
const isFuncCall = ast => {
    return ast.type == "FunctionCall"
}

const checkType = type => {
    if (type && String(type).includes("int")){
        if (String(type) == "uint" || String(type) == "int"){
            return 256
        }else{
            return Number.parseInt(String(type).slice(String(type).indexOf("int")+3))
        }
    }else{
        return 0
    }
}

module.exports = {
    fixOverUnderFlow: (contractsAst, option) => {
        if (!option.configJson.IOU) return contractsAst
        const template = new Template()
        const targetFunctions = option.configJson.IOU.map(obj => obj.function_name)

        // elimate side effect
        // a[exp] += 1 -----> let ind = exp; a[ind] += 1
        const postFunc = []
        parser.visit(contractsAst, {
            ExpressionStatement(ast, parent) {
                const contract = findContract(ast, contractsAst)
                const func = findFunc(ast, contract)
                if (!func || !contract) return
                // check if this is a target function
                const funcName = func.name != "" ? func.name : "fallback"
                if (!targetFunctions.includes(`${contract.name}::${funcName}`)) return

                if (ast.expression.type != "BinaryOperation") return
                const {left} = ast.expression
                if ( left.type == "IndexAccess" &&!isAssignment(left.index) && !isFuncCall(left.index)) return
                if (
                    ast.expression.operator == "+=" ||
                    ast.expression.operator == "-=" ||
                    ast.expression.operator == "/=" ||
                    ast.expression.operator == "*="
                ) {
                    const {left, right} = ast.expression
                    const assignAst = elimateSideEffect(left, contractsAst)
                    if (assignAst) {
                        postFunc.push(() => {
                            parent.statements.splice(
                                parent.statements.indexOf(ast),
                                0,
                                assignAst)
                        })
                    }
                }
                // console.log(ast)
            },
        })
        postFunc.forEach(f => f())

        //transform
        parser.visit(contractsAst, {
            // eg. arr[ind] += 1 --> arr[ind] = arr[ind] + 1
            ExpressionStatement(ast, parent) {
                const contract = findContract(ast, contractsAst)
                const func = findFunc(ast, contract)
                if (!func || !contract) return
                
                // check if this is a target function
                const funcName = func.name != "" ? func.name : "fallback"
                if (!targetFunctions.includes(`${contract.name}::${funcName}`)) return
                if (ast.expression.type == "BinaryOperation") {
                    if (
                        ast.expression.operator == "+=" ||
                        ast.expression.operator == "-=" ||
                        ast.expression.operator == "/=" ||
                        ast.expression.operator == "*="
                    ) {
                        const opMap = {
                            "+=": "+",
                            "-=": "-",
                            "*=": "*",
                            "/=": "/",
                        }
                        const op = opMap[ast.expression.operator]
                        ast.expression = {
                            ...ast.expression,
                            operator: "=",
                            right: {
                                ...ast.expression.right,
                                type: "BinaryOperation",
                                operator: op,
                                left: ast.expression.left,
                                right: ast.expression.right,
                            }
                        }
                    }
                }
                if (ast.expression.type == "UnaryOperation") {
                    if (
                        ast.expression.operator == "++" ||
                        ast.expression.operator == "--"
                    ) {
                        const opMap = {
                            "++": "+",
                            "--": "-",
                        }
                        const op = opMap[ast.expression.operator]
                        ast.expression = {
                            ...ast.expression,
                            type:"BinaryOperation",
                            operator: "=",
                            right: {
                                loc: ast.expression.subExpression.loc,
                                type: "BinaryOperation",
                                operator: op,
                                left: {...ast.expression.subExpression},
                                right: {
                                    type: "NumberLiteral",
                                    number: "1",
                                    subdenomination: null,
                                    loc: ast.expression.subExpression.loc,
                                },
                            },
                            left:{
                                ...ast.expression.subExpression
                            }
                        }
                    }
                }

                // type resolve
                if (ast.expression.operator == "+=" ||
                    ast.expression.operator == "-=" ||
                    ast.expression.operator == "*=" ||
                    ast.expression.operator == "/=" ||
                    ast.expression.operator == "="
                    ) {
                    const leftTyp = getType(ast.expression.left, contractsAst)
                    if (leftTyp) {
                        parser.visit(ast.expression.right, {
                            BinaryOperation(ast) {
                                if (ast.operator == "+" ||
                                    ast.operator == "-" ||
                                    ast.operator == "*" ||
                                    ast.operator == "/" 
                                    ) {
                                    ast.leftTyp = leftTyp
                                }
                            }
                        })
                    }
                }


            },
        })

        const postFunc2 = []
        // add safe method
        parser.visit(contractsAst, {
            BinaryOperation(ast, parent) {
                const contract = findContract(ast, contractsAst)
                const func = findFunc(ast, contract)
                if (!func || !contract) return
                // check if this is a target function
                const funcName = func.name != "" ? func.name : "fallback"
                if (!targetFunctions.includes(`${contract.name}::${funcName}`)) return
                if (
                    ast.operator == "+" ||
                    ast.operator == "-" ||
                    ast.operator == "/" ||
                    ast.operator == "*" ||
                    ast.operator == "**"
                ) {
                    const methodMap = {
                        "+": "add",
                        "-": "sub",
                        "/": "div",
                        "*": "mul",
                        "**": "pow"
                    }
                    let typ = null
                    if (["=","+=","-=","*=","/="].includes(parent.operator)){
                        typ = getType(parent.left, contractsAst)
                    }

                    if (!typ || !String(typ).includes("int")){
                        const ltyp = getType(ast.left, contractsAst)
                        const rtyp = getType(ast.right, contractsAst)
                        if ((!ltyp || !String(ltyp).includes("int")) && (!String(rtyp) || !String(rtyp).includes("int"))) return
                        const ltypNum = checkType(ltyp)
                        const rtypNum = checkType(rtyp)
                        typ = (ltypNum || rtypNum) && ltypNum >= rtypNum ? ltyp : rtyp
                    }
                    
                    const safeMethodName = template[methodMap[ast.operator]](typ)
                    const contract = findContract(ast, contractsAst)
                    if (!contract.sguardplus) {
                        contract.sguardplus = []
                    }

                    
                    Object.entries(parent).forEach(([k, v]) => {
                        if (v === ast) {
                            postFunc2.push(() => {
                                parent[k] = {
                                    type: "FunctionCall",
                                    arguments: [ast.left, ast.right],
                                    expression: {
                                        type: "Identifier",
                                        name: safeMethodName
                                    },
                                    names: []
                                }
                            })
                            if (ast.operator == "**"){
                                contract.sguardplus.push(template[methodMap["+"]](typ))
                                contract.sguardplus.push(template[methodMap["*"]](typ))
                                contract.sguardplus.push(safeMethodName)
                            }else {
                                contract.sguardplus.push(safeMethodName)
                            }
                        } else if(k == "components"){
                            Object.entries(parent.components).forEach(([k, v]) => {
                                if (v === ast) {
                                    postFunc2.push(() => {
                                        parent.components[k] = {
                                            type: "FunctionCall",
                                            arguments: [ast.left, ast.right],
                                            expression: {
                                                type: "Identifier",
                                                name: safeMethodName
                                            },
                                            names: []
                                        }
                                    })
                                    if (ast.operator == "**"){
                                        contract.sguardplus.push(template[methodMap["+"]](typ))
                                        contract.sguardplus.push(template[methodMap["*"]](typ))
                                        contract.sguardplus.push(safeMethodName)
                                    }else {
                                        contract.sguardplus.push(safeMethodName)
                                    }
                                }
                            })
                        } else if(k == "arguments"){
                            Object.entries(parent.arguments).forEach(([k, v]) => {
                                if (v === ast) {
                                    postFunc2.push(() => {
                                        parent.arguments[k] = {
                                            type: "FunctionCall",
                                            arguments: [ast.left, ast.right],
                                            expression: {
                                                type: "Identifier",
                                                name: safeMethodName
                                            },
                                            names: []
                                        }
                                    })
                                    if (ast.operator == "**"){
                                        contract.sguardplus.push(template[methodMap["+"]](typ))
                                        contract.sguardplus.push(template[methodMap["*"]](typ))
                                        contract.sguardplus.push(safeMethodName)
                                    }else {
                                        contract.sguardplus.push(safeMethodName)
                                    }
                                }
                            })
                        }
                    })
                }
            }
        })   

        postFunc2.reverse().forEach(f => f())




        return contractsAst
    }
}