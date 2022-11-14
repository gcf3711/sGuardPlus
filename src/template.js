



class Template {
        constructor() {
                this.helps = new Set()
        }

        add(typ) {
                const method = `add_${typ}`
                this.helps.add(method)
                return method
        }

        sub(typ) {
                const method = `sub_${typ}`
                this.helps.add(method)
                return method
        }

        mul(typ) {
                const method = `mul_${typ}`
                this.helps.add(method)
                return method
        }

        div(typ) {
                const method = `div_${typ}`
                this.helps.add(method)
                return method
        }

        pow(typ) {
                const method = `pow_${typ}`
                this.helps.add(method)
                return method
        }
}




module.exports = {
        Template
}