const parser = require("@solidity-parser/parser")
const genSguardPlus = require("./sguardplus").genSguardPlus

class RevertBase {
	constructor(option) {
		this.option = option
	}

	appendStr(str) {
		this.option.builder += str
	}
	appendSemi() {
		this.appendStr(";")
	}
	popChar() {
		const v = this.option.builder.split("")
		v.pop()
		this.option.builder = v.join("")
	}

	appendNewLine() {
		this.appendStr("\n")
	}

	visitParams(params) {
		if (!params) return ""
		const quilifier = para => para.isIndexed ? "indexed" :
			para.isDeclaredConst ? "constant" :
				""
		const storage = para => para.storageLocation ? para.storageLocation : ""
		const name = para => para.name ? para.name : ""
		return params
			.map(para => `${this.visitTypeName(para.typeName)} ${quilifier(para)} ${storage(para)} ${name(para)}`)
			.join(",")
	}
	visitTypeName(type) {
		if (!type) return
		const t = type.type
		if (t === "ElementaryTypeName") {
			return `${type.name} ${type.stateMutability ? type.stateMutability : ""}`
		}
		else if (t === "UserDefinedTypeName") {
			return `${type.namePath} ${type.stateMutability ? type.stateMutability : ""}`
		}
		else if (t === "Mapping") {
			return `mapping (${this.visitTypeName(type.keyType)} => ${this.visitTypeName(type.valueType)})`
		}
		else if (t === "ArrayTypeName") {
			return `${this.visitTypeName(type.baseTypeName)}[${type.length ? type.length.number ? type.length.number : this.visitTypeName(type.length) : ""}]`
		}
		else if (t === "BinaryOperation") {
			return `${this.visitTypeName(type.left)} ${type.operator} ${this.visitTypeName(type.right)}`
		}
		else if (t === "NumberLiteral") {
			return `${type.number}`
		}
		else {
			throw new Error("type name error")
		}
	}
}



class RevertTop extends RevertBase {
	constructor(option) {
		super(option)
		this.option = option
	}

	start(ast) {
		const visitor =
		{
			SourceUnit: (ast) => {
				const pragmas = ast.children.filter(v => v.type == "PragmaDirective")
				pragmas.forEach(child => this.start(child))

				ast.children.forEach(child => {
					child?.sguardplus?.forEach(s => {
						this.option.sguardPlus.add(s)
					})
					child?.sguardplusForRen?.forEach(s => {
						this.option.sguardPlusForRen.add(s)
					})
					if (child.sguardPlusForSui) {
						this.option.sguardPlusForSui = true
					}
				})
				this.appendStr(genSguardPlus(this.option))
				
				const others = ast.children.filter(v => v.type !== "PragmaDirective")
				others.forEach(child => this.start(child))
			},
			PragmaDirective: (ast, parent) => {
				const rexp = new RevertExp(this.option)
				this.appendStr(`pragma ${ast.name} ${ast.value}`)
				this.appendSemi()
				this.appendNewLine()

			},
			// ImportDirective: (ast) => {
			// 	// ast.
			// 	// this.appendStr(`import `)
			// },
			ContractDefinition: (ast) => {
				const sguardPlus = (ast.sguardplus || ast.sguardplusForRen || ast.sguardPlusForSui) ? ["sGuardPlus"] : []
				const parents = sguardPlus.concat(ast.baseContracts.map(parent => parent.baseName.namePath)).join(",")
				this.appendStr(`${ast.kind} ${ast.name} ${parents ? `is ${parents}` : ""} {\n`)
				ast.subNodes.forEach(node => {
					this.start(node)
					// this.appendSemi()
				})
				this.appendStr("}")
				this.appendNewLine()
			},
			EnumDefinition: (ast) => {
				this.appendStr(`enum ${ast.name} {`)
				this.appendNewLine()
				for (let i = 0; i < ast.members.length; i++) {
					this.appendStr(ast.members[i].name)
					if (i !== ast.members.length - 1) {
						this.appendStr(", ")
					}
					this.appendNewLine()
				}
				this.appendStr("}")
				this.appendNewLine()
			},
			StructDefinition: (ast) => {
				this.appendStr(`struct ${ast.name} {`)
				this.appendNewLine()
				const rstmt = new RevertStmt(this.option)
				ast.members.forEach(member => {
					rstmt.start(member)
					this.appendSemi()
					this.appendNewLine()
				})
				this.appendStr("}")
				this.appendNewLine()
			},
			FunctionDefinition: (ast) => {
				let head
				let tail = ""
				if (ast.isConstructor) {
					head = `constructor`
				}
				else if (ast.isFallback) {
					head = `function`
				}
				else if (ast.isReceiveEther) {
					head = `receiver`
				}
				else {
					head = `function ${ast.name}`
					if (ast.returnParameters) {
						const retParams = this.visitParams(ast.returnParameters)
						tail = `returns (${retParams})`
					}
				}
				const params = this.visitParams(ast.parameters)
				const visibility = ast.visibility === "default" ? "" : ast.visibility
				this.appendStr(`${head} (${params}) ${visibility} `)
				ast.modifiers.forEach(mo => {
					this.start(mo)
					this.appendStr(" ")
				})
				this.appendStr(`${ast.stateMutability ? ast.stateMutability : ""} ${tail}`)
				// const modifiers = ast.modifiers.map(mo => this.modifierInvocation(mo)).join(" ")

				const revertStmt = new RevertStmt(this.option)
				revertStmt.start(ast.body)
				if (!ast.body)
					this.appendSemi()
				this.appendNewLine()
			},
			// FileLevelConstant(ast) {
			// 	console.log("todo: file level")
			// },
			// CustomErrorDefinition(ast) {
			// 	console.log("todo: custom")
			// },

			// contract part below
			StateVariableDeclaration: decl => {
				// decl.variables.forEach(var => this.appendStr(var))
				const rstmt = new RevertStmt(this.option)
				decl.variables.forEach((res) => rstmt.start(res));
				if (decl.initialValue) {
					this.appendStr(" = ")
					const sexp = new RevertExp(this.option)
					sexp.start(decl.initialValue)
				}
				this.appendSemi()
				this.appendNewLine()
			},
			UsingForDeclaration: (decl) => {
				const typeName = this.visitTypeName(decl.typeName)
				this.appendStr(`using ${decl.libraryName} for ${typeName}`)
				this.appendSemi();
				this.appendNewLine();
			},
			ModifierDefinition: (modifier) => {
				const param = modifier.parameters ? `(${this.visitParams(modifier.parameters)})` : ""
				this.appendStr(`modifier ${modifier.name} ${param}`)
				const rstmt = new RevertStmt(this.option)
				rstmt.start(modifier.body)
			},
			EventDefinition: (ast) => {
				const params = this.visitParams(ast.parameters)
				this.appendStr(`event ${ast.name} (${params})`)
				this.appendSemi()
				this.appendNewLine()
			},
			ModifierInvocation: (mo) => {
				this.appendStr(`${mo.name}`)
				if (mo.arguments) {
					this.appendStr("(")
					const rexp = new RevertExp(this.option)
					for (let i = 0; i < mo.arguments.length; i++) {
						rexp.start(mo.arguments[i])
						if (i !== mo.arguments.length - 1)
							this.appendStr(", ")
					}
					this.appendStr(")")
				}
			}
		}
		if (visitor[ast.type]) {
			const f = visitor[ast.type]
			f(ast)
		} else {
			throw new Error(`${ast.type} unimpl`)
		}
	}

}

class RevertExp extends RevertBase {
	constructor(option) {
		super(option)
		this.option = option
	}

	start(ast) {
		if (!ast) return
		const visitor = {
			IndexAccess: (exp) => {
				this.start(exp.base)
				this.appendStr("[")
				this.start(exp.index)
				this.appendStr("]")
			},
			// IndexRangeAccess() { },
			TupleExpression: (exp) => {
				if (exp.isArray)
					this.appendStr("[")
				else
					this.appendStr("(")

				for (let i = 0; i < exp.components.length; i++) {
					this.start(exp.components[i])
					if (i !== exp.components.length - 1) {
						this.appendStr(", ")
					}
				}

				if (exp.isArray)
					this.appendStr("]")
				else
					this.appendStr(")")

			},
			BinaryOperation: (exp) => {
				this.start(exp.left)
				this.appendStr(exp.operator)
				this.start(exp.right)
			},
			// Conditional() { },
			MemberAccess: (exp) => {
				this.start(exp.expression)
				this.appendStr(".")
				this.appendStr(exp.memberName)
			},
			FunctionCall: (exp) => {
				this.start(exp.expression)
				this.appendStr("(")
				if (exp.names.length > 0) {
					this.appendStr("{")
					for (let i = 0; i < exp.names.length; i++) {
						this.appendStr(`${exp.names[i]}: `)
						this.start(exp.arguments[i])
						if (i !== exp.names.length - 1) {
							this.appendStr(", ")
						}
					}
					this.appendStr("}")
				} else {
					for (let i = 0; i < exp.arguments.length; i++) {
						this.start(exp.arguments[i])
						if (i !== exp.arguments.length - 1)
							this.appendStr(", ")
					}
				}
				this.appendStr(")")
			},
			UnaryOperation: (exp) => {
				if (exp.isPrefix) {
					this.appendStr(` ${exp.operator} `)
					this.start(exp.subExpression)
				} else {
					this.start(exp.subExpression)
					this.appendStr(` ${exp.operator} `)
				}
			},
			NewExpression: exp => {
				const t = this.visitTypeName(exp.typeName)
				this.appendStr(`new ${t}`)
			},
			// NameValueExpression(exp) { },
			BooleanLiteral: (exp) => {
				this.appendStr(exp.value)
			},
			HexLiteral: (exp) => {
				this.appendStr(exp.value)
			},
			StringLiteral: (exp) => {
				this.appendStr(`"${exp.value}"`)
			},
			NumberLiteral: (exp) => {
				this.appendStr(exp.number)
				if (exp.subdenomination) {
					this.appendStr(" " + exp.subdenomination)
				}
			},
			DecimalNumber: exp => {
				this.appendStr(exp.value)
			},
			Identifier: (exp) => {
				this.appendStr(exp.name)
			},
			TypeNameExpression: (exp) => {
				this.appendStr(this.visitTypeName(exp.typeName))
			},
			AssemblyCall: exp => {
				if (exp.arguments.length == 0) {
					this.appendStr(exp.functionName)
					return
				}
				this.appendStr(`${exp.functionName}(`)
				for (let i = 0; i < exp.arguments.length; i++) {
					this.start(exp.arguments[i])
					if (i !== exp.arguments.length - 1) {
						this.appendStr(", ")
					}
				}
				this.appendStr(")")
			},
			Conditional: exp => {
				this.start(exp.condition)
				this.appendStr(" ? ")
				this.start(exp.trueExpression)
				this.appendStr(" : ")
				this.start(exp.falseExpression)
			},
			HexNumber: exp => {
				this.appendStr(exp.value)
			}
		}
		if (visitor[ast.type]) {
			const f = visitor[ast.type]
			f(ast)
		} else {
			throw new Error(`${ast.type} unimpl`)
		}
	}
}

class RevertStmt extends RevertBase {
	constructor(option) {
		super(option)
		this.option = option
	}

	handleBuggyLine(stmt) {
		if (stmt.__markBuggy) {
			this.appendStr(stmt.__buggyComment)
		}
	}

	start(ast) {
		if (!ast) return
		const rexp = new RevertExp(this.option)
		const visitor = {
			Block: (ast) => {
				this.appendStr("{")
				this.appendNewLine()
				ast.statements.forEach(stmt => {
					this.start(stmt)
				})
				this.appendStr("}")
				this.appendNewLine()
			},
			VariableDeclaration: (decl) => {
				let visibility = ""
				if (decl.visibility !== "default" && decl.visibility) {
					visibility = decl.visibility
				}
				let isConst = ""
				if (decl.isDeclaredConst) {
					isConst = "constant"
				}
				const storage = decl.storageLocation ? decl.storageLocation : ""
				this.appendStr(`${this.visitTypeName(decl.typeName)} ${visibility} ${isConst} ${storage} ${decl.name}`)
				this.handleBuggyLine(decl)
			},
			ExpressionStatement: (ast) => {
				const rexp = new RevertExp(this.option)
				if (ast.expression) {
					rexp.start(ast.expression)
					this.appendSemi()
					this.handleBuggyLine(ast)
					this.appendNewLine()
				}
			},
			IfStatement: (stmt) => {
				this.appendStr(`if (`)
				rexp.start(stmt.condition)
				this.appendStr(")")
				this.appendNewLine()
				this.start(stmt.trueBody)
				if (stmt.falseBody) {
					this.appendStr(" else ")
					this.appendNewLine()
					this.start(stmt.falseBody)
					this.appendNewLine()
					return
				}
				this.handleBuggyLine(stmt)
				this.appendNewLine()
			},
			// TryStatement: () => { },
			WhileStatement: (stmt) => {
				this.appendStr(`while (`)
				const rexp = new RevertExp(this.option)
				rexp.start(stmt.condition)
				this.appendStr(")")
				this.start(stmt.body)
				this.handleBuggyLine(stmt)
				this.appendNewLine()
			},
			ForStatement: (stmt) => {
				this.appendStr(`for(`)
				this.handleBuggyLine(stmt)
				const rexp = new RevertExp(this.option)
				if (stmt.initExpression){
					this.start(stmt.initExpression)
					this.popChar()
				}else{
					this.appendStr("; ")
				}
				rexp.start(stmt.conditionExpression)
				this.appendStr("; ")
				rexp.start(stmt.loopExpression.expression)
				this.appendStr(")")
				this.start(stmt.body)
				this.appendNewLine()
			},
			// InlineAssemblyStatement: () => { },
			// DoWhileStatement: () => { },
			ContinueStatement: (stmt) => {
				this.appendStr("continue")
				this.appendSemi()
				this.handleBuggyLine(stmt)
				this.appendNewLine()
			},
			// BreakStatement: () => { },
			ReturnStatement: (stmt) => {
				this.appendStr("return ")
				rexp.start(stmt.expression)
				this.appendSemi()
				this.handleBuggyLine(stmt)
				this.appendNewLine()
			},
			// ThrowStatement: () => { },
			EmitStatement: (stmt) => {
				this.appendStr(`emit `)
				rexp.start(stmt.eventCall)
				this.appendSemi()
				this.handleBuggyLine(stmt)
				this.appendNewLine()
			},
			// SimpleStatement: (stmt) => {
			// 	console.log(stmt)
			// },
			// UncheckedStatement: () => { },
			// RevertStatement: () => { },
			VariableDeclarationStatement: (stmt) => {
				if (stmt.variables.length > 1) {
					this.appendStr("(")
				}
				for (let i = 0; i < stmt.variables.length; i++) {
					this.start(stmt.variables[i])
					if (i !== stmt.variables.length - 1) {
						this.appendStr(", ")
					}
				}
				if (stmt.variables.length > 1) {
					this.appendStr(")")
				}
				if (!stmt.initialValue) {
					this.appendSemi()
					this.handleBuggyLine(stmt)
					this.appendNewLine()
					return
				}
				this.appendStr(" = ")
				const rexp = new RevertExp(this.option)
				rexp.start(stmt.initialValue)
				this.appendSemi()
				this.handleBuggyLine(stmt)
				this.appendNewLine()
			},
			InlineAssemblyStatement: stmt => {
				this.appendStr("assembly")
				this.start(stmt.body)
			},
			AssemblyBlock: block => {
				this.appendStr("{")
				this.appendNewLine()
				block.operations.forEach(op => this.start(op))
				this.appendStr("}")
				// this.appendSemi()
				this.appendNewLine()
			},
			AssemblyAssignment: stmt => {
				this.start(stmt.name)
				stmt.names.forEach(name => {
					if (name.type !== "Identifier")
						throw new Error("assigned variable is not a identifier")
				})
				const name = stmt.names.map(id => id.name).join(",")
				this.appendStr(`${name} := `)
				const rexp = new RevertExp(this.option)
				rexp.start(stmt.expression)
				this.appendNewLine()
			},
			AssemblyLocalDefinition: stmt => {
				this.start(stmt.name)
				stmt.names.forEach(name => {
					if (name.type !== "Identifier")
						throw new Error("assigned variable is not a identifier")
				})
				const name = stmt.names.map(id => id.name).join(",")
				this.appendStr(`let ${name} := `)
				const rexp = new RevertExp(this.option)
				rexp.start(stmt.expression)
				this.appendNewLine()
			},
			AssemblyCall: stmt => {
				const rexp = new RevertExp(this.option)
				rexp.start(stmt)
				this.appendNewLine()
			},
			ThrowStatement: stmt => {
				this.appendStr("throw;")
				// this.appendNewLine()
			}

		}
		if (visitor[ast.type]) {
			const f = visitor[ast.type]
			f(ast)
		} else {
			throw new Error(`${ast.type} unimpl`)
		}
	}
}

class Revert {
	constructor() {
		this.init()
	}

	init() {
		this.option = {
			builder: "",
			indent: 0,
			sguardPlus: new Set(),
			sguardPlusForRen: new Set(),
			sguardPlusForSui: false,
			appendStr(str) {
				this.builder += str
			},
			appendSemi() {
				this.appendStr(";")
			},
			appendNewLine() {
				this.appendStr("\n")
			}
		}
	}

	start(ast) {
		const top = new RevertTop(this.option);
		top.start(ast)
		return this.option.builder;
	}
}

module.exports = {
	Revert
}