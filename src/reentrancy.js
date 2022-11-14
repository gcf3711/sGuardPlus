const parser = require("@solidity-parser/parser")

const ftrace = require("surya").ftrace


const callGraphAnalysis = (contract, option) => {
    const {
        name,
        subNodes
    } = contract
    const funcs = subNodes.filter(node => node.type === "FunctionDefinition")
    const graph = {
        contractName: name,
        subFuncs: {}
    }
    funcs.forEach(func => {
        let functionName = func.name
        if (func.isConstructor) {
          functionName = '<Constructor>';
        } else if (func.isFallback) {
          functionName = '<Fallback>';
        } else if (func.isReceiveEther) {
          functionName = '<Receive Ether>';
        }

        const path = `${name}::${functionName}`
        try{
            const trace = ftrace(path, "internal", [option.filePath], {
                jsonOutput: true
            })
            const trace2 = ftrace(path, "external", [option.filePath], {
                jsonOutput: true
            })
            graph.subFuncs[path] = {
                ...trace[path],
                ...trace2[path]
            }
        }catch(error){
            console.log(error)
        }
        
    })

    const clear = graph => {

        const rec = obj => {
            const res = {}
            Object.entries(obj).forEach(([k, v]) => {
                if (!v) return
                res[k] = Object.keys(v).map(k => k.split("|")[0].trim())
            })
            return res
        }

        return {
            ...graph,
            subFuncs: rec(graph.subFuncs)
        }
    }
    const result = clear(graph)

    return result
}

const findRing = graph => {
    const visited = new Set()

    const dfs = (path, stack) => {
        if (!stack.length) {
            return []
        }
        const unVisitedKey = stack.pop()
        if (path.includes(unVisitedKey)) {
            const i = path.indexOf(unVisitedKey)
            const ring = path.slice(i)
            return [[...ring, unVisitedKey]]
        } else {
            visited.add(unVisitedKey)
            const outs = graph.subFuncs[unVisitedKey]
            if (!outs) return []
            return outs.flatMap(out => {
                return dfs([...path, unVisitedKey], [out])
            })
        }
    }

    const rings = []
    while(Object.keys(graph.subFuncs).some(k => !visited.has(k))) {
        const unVisitedKey = Object.keys(graph.subFuncs).find(k => !visited.has(k))
        rings.push(...dfs([], [unVisitedKey]))
    }
    return rings
}

function reachable(graph, node1, node2) {
    console.log(graph)
}

let tmp = 100
function genSym(i) {
    return `__lock_modifier${i === undefined ? ++tmp : i}`
}

function useModifier(contractsAst, option, contractName, funcName, i) {
    const contract = contractsAst.children.find(v => v.name === contractName)
    const targetFunc = contract.subNodes.find(v => v.name === funcName)
    const modifierName = genSym(i)
    targetFunc.modifiers.push({
        arguments: null,
        name: modifierName,
        type: "ModifierInvocation"
    })
    if (!contract.sguardplusForRen) {
        contract.sguardplusForRen = []
    }
    contract.sguardplusForRen.push(modifierName)
}

function useMove(contractsAst, option, contractName, funcName, strategy) {
    const [line1, line2] = strategy.repair_location
    let success = false
    parser.visit(contractsAst, {
        FunctionDefinition(ast, parent) {
            const stmts = ast.body.statements
            if (!stmts) return false
            const line1Index = stmts.findIndex(stmt => stmt.loc.start.line === line1)
            const line2Index = stmts.findIndex(stmt => stmt.loc.start.line === line2)
            if (line1Index >= 0 && line2Index >= 0) {
                const tmp = stmts[line1Index]
                stmts[line1Index] = stmts[line2Index]
                stmts[line2Index] = tmp
                success = true
            }
        }
    })
    return success
}


const getUnconnectedSubGraphs = (callGraphs, notInRing) => {
    const nodeMap = {}
    const ins = {}
    const outs = {}


    callGraphs.forEach(graph => {
        Object.entries(graph.subFuncs).forEach(([path, dests]) => {
            nodeMap[path] = dests
            if (!outs[path]) {
                outs[path] = dests.length
            } else {
                outs[path] += dests.length
            }
            if (!ins[path]) {
                ins[path] = 0
            }
            dests.forEach(dest => {
                if (!ins[dest]) {
                    ins[dest] = 1
                } else {
                    ins[dest] += 1
                }
            })
        })
    })

    const subGraphs = []

    Object.keys(ins).forEach(path => {
        if (ins[path]) return

        const rec = path => {
            const currentOuts = outs[path]
            if (!currentOuts) {
                return [[path]]
            }
            const traces = nodeMap[path].flatMap(outPath => rec(outPath)) 
            return traces.map(trace => [path, ...trace])
        }
        subGraphs.push(...rec(path))

    })

    const traces = []
    subGraphs.forEach(trace => {
        const filtered = trace.filter(path => notInRing.find(v => v.function_name == path))
        if (filtered.length)
            traces.push(filtered)
    })

    return traces
}

module.exports = {
    fixReentancy: (contractsAst, option) => {
        if (!option.configJson.REN) return contractsAst
        const callGraphs = contractsAst.children.filter(cont => cont.type == "ContractDefinition")
                                       .map(cont => callGraphAnalysis(cont, option))

        const rings = callGraphs.map(graph => {
            const rings = findRing(graph)
            return {
                graph,
                rings
            }
        })

        const {configJson: {REN}} = option
        
        const notInRing = REN.filter(config => {
            const {function_name} = config
            // const [contractName, funcName] = function_name.split("::")
            const res = rings.find(ring => {
                return ring.rings.some(lst => lst.includes(function_name))
            })
            return !res
        })

        const traces = getUnconnectedSubGraphs(callGraphs, notInRing)



        const inRings = REN.filter(v => !notInRing.includes(v))
        option.report.cycleCall.push(...inRings)


        const visited = {}
        traces.forEach(trace => {
            let i = 0
            trace.forEach(path => {
                const config = notInRing.find(config => config.function_name == path)
                const {function_name, strategys} = config
                const [contractName, funcName] = function_name.split("::")
                if (strategys[0].type === "move") {
                    const success = useMove(contractsAst, option, contractName, funcName, strategys[0])
                    if (!success){
                        if (visited[path]) {
                            return
                        }
                        useModifier(contractsAst, option, contractName, funcName, i++)
                        visited[path] = true
                    }
                } else if (strategys[0].type === "modifier") {
                    if (visited[path]) {
                        return
                    }
                    useModifier(contractsAst, option, contractName, funcName, i++)
                    visited[path] = true
                } else {
                    throw new Error("unknow strategy type")
                }

            })
        })

        // notInRing.forEach(config => {
        //     const {function_name, strategys} = config
        //     const [contractName, funcName] = function_name.split("::")
        //     if (strategys[0].type === "move") {
        //         const success = useMove(contractsAst, option, contractName, funcName, strategys[0])
        //         if (!success){
        //             useModifier(contractsAst, option, contractName, funcName)
        //         }
        //     } else if (strategys[0].type === "modifier") {
        //         useModifier(contractsAst, option, contractName, funcName)
        //     } else {
        //         throw new Error("unknow strategy type")
        //     }
        // })
        
        return contractsAst
    }
}