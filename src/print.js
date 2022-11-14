const parser = require("@solidity-parser/parser")
const path = require("path")
const fs = require("fs")
const Revert = require("./revert2src").Revert


let examplePath
examplePath = path.join(__dirname, `../contracts/24.sol`)
const exampleContent = fs.readFileSync(examplePath)
const exampleSrc = exampleContent.toString()
const ast = parser.parse(exampleSrc)

const revert = new Revert()

try {
	const revertedSrc = revert.start(ast)
	console.log(revertedSrc)
} catch (e) {
	console.log(`error: ${i}.sol \n ${e}`)
}

for (let i = 1; i <= 50; i++) {
	let examplePath
	examplePath = path.join(__dirname, `../contracts/${i}.sol`)
	const exampleContent = fs.readFileSync(examplePath)
	const exampleSrc = exampleContent.toString()
	const ast = parser.parse(exampleSrc)

	const revert = new Revert()

	try {
		const revertedSrc = revert.start(ast)
	} catch (e) {
		console.log(`error: ${i}.sol \n ${e}`)
	}


	// console.log(revertedSrc)
}
