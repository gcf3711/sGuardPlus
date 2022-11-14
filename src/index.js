const parser = require("@solidity-parser/parser")
const fs = require("fs")
const path = require("path")
const Revert = require("./revert2src.js").Revert
const fixSuicide = require("./suicide.js").fixSuicide
const fixTxOrigin = require("./txorigin.js").fixTxOrigin
const fixOverUnderFlow = require("./overunderflow.js").fixOverUnderFlow
const fixReentancy = require("./reentrancy").fixReentancy
const fixUnchecked = require("./unchecked").fixUnchecked
const shell = require('shelljs')

if (process.argv.length <= 2){
    console.error('Expected the path of original smart contract');
    process.exit(1);
} else {
    const { code } = shell.exec(`python ${__dirname}/../slither_func2vec/__main__.py  ${process.argv[2]} --print sguard_plus`)
    if (code != 0) {
        console.log(`[+] Failed to detect vulnerabilities by Slither`)
        return
    } 
}

Math.seed = 6;
Math.random = function (max, min) {
	max = max || 1;
	min = min || 0;
	Math.seed = (Math.seed * 9301 + 49297) % 233280;
	var rnd = Math.seed / 233280;

	return min + rnd * (max - min);
}

class FixManager {

    constructor(ast, option) {
        this.ast = ast
        this.option = option
        this.passes = []
    }

    add(pass) {
        this.passes.push(pass)
        return this
    }

    run() {
        const fixed = this.passes.reduce((ast, pass) => pass(ast, this.option), this.ast)
        return fixed
    }
}


const start = (option) => {
	const {
		filePath,
        configPath
	} = option
    if (!filePath) console.error("need filePath")
    if (!configPath) console.error("need configPath")
    
    const fileContent = fs.readFileSync(filePath)
    const src = fileContent.toString()
    const ast = parser.parse(src, {loc:true})
    const configContent = fs.readFileSync(configPath)
    option.configJson = JSON.parse(configContent.toString())

    // check whether the contract is vulnerable
    var vul = false
    for (var key in option.configJson){
        if (option.configJson[key].length != 0){
            if (key == "UCR"){
                option.configJson[key].forEach( v => {
                    if (v["strategys"][0]["repair_location"].length != 0){
                        vul = true
                    }
                })
            } else {
                vul = true
            }
        }
    }
    if (!vul) return


    const fixedAst = new FixManager(ast, option)
                        .add(fixReentancy)
                        .add(fixTxOrigin)
                        .add(fixOverUnderFlow)
                        .add(fixUnchecked)
                        .add(fixSuicide)
                        .run()
    
    
    const revert = new Revert()
    const revertedSrc = revert.start(fixedAst)
    const fixedFile = filePath.concat(".fixed.sol")
    fs.writeFileSync(fixedFile, revertedSrc, 'utf8')
    console.log(filePath+" fixed!")
}


const option = {
    filePath: process.argv[2],
    configPath: process.argv[2].concat("_vul_report.json"),
    report: {
        cycleCall: []
    }
}

const result = start(option)




