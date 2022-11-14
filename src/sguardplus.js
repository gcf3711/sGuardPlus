
const genMethod = sguardPlus => {
        return Array.from(sguardPlus).map(methodName => {
                const typ = methodName.match(/_.+/)[0].slice(1)
                if (methodName.startsWith("add")) {
                        return `function ${methodName}(${typ} a, ${typ} b) internal pure returns (${typ}) {
                                ${typ} c = a + b;
                                assert(c >= a);
                                return c;
                        }`
                } else if (methodName.startsWith("sub")) {
                        return `function ${methodName}(${typ} a, ${typ} b) internal pure returns (${typ}) {
                                assert(b <= a);
                                return a - b;
                        }`

                } else if (methodName.startsWith("div")) {
                        return `function ${methodName}(${typ} a, ${typ} b) internal pure returns (${typ}) {
                                ${typ} c = a / b;
                                return c;
                        }`
                } else if (methodName.startsWith("mul")) {
                        return `function ${methodName}(${typ} a, ${typ} b) internal pure returns (${typ}) {
                                if (a == 0) {
                                        return 0;
                                }
                                ${typ} c = a * b;
                                assert(c / a == b);
                                return c;
                        }`
                }  else if (methodName.startsWith("pow")) {
                        return `function ${methodName}(${typ} a, ${typ} b) internal pure returns (${typ}) {
                                ${typ} c = 1;
                                for(${typ} i = 0; i < b; i = add_${typ}(i, 1)){
                                        c = mul_${typ}(c, a);
                                }
                                return c;
                        }`
                } else {
                        return ``
                }
                
        }).join("\n")
}

const genModifier = sguardPlusForRen => {
        return Array.from(sguardPlusForRen).map(modifierName => {
                const lockName = `${modifierName}_lock`
                return `
                bool private ${lockName};
                modifier ${modifierName}() {
                        require(!${lockName});
                        ${lockName} = true;
                        _;
                        ${lockName} = false;
                        
                }
                `
        }).join("\n")
}

const genModifierLock = sguardPlusForRen => {
        return Array.from(sguardPlusForRen).map(modifierName => {
                const lockName = `${modifierName}_lock`
                return `${lockName} = false;`
        }).join("\n")
}

const genSuiCtor = sguardPlusForSui => {
        if (sguardPlusForSui) {
                return `__owner = msg.sender;`
        }
        return ``
}

const genSui = sguardPlusForSui => {
        if (sguardPlusForSui) {
                return `
                address private __owner;
                modifier __onlyOwner() {
                        require(msg.sender == __owner);
                        _;
                }
                `
        }
        return ``
}

module.exports = {
        genSguardPlus: option => {
                const {
                        sguardPlus,
                        sguardPlusForRen,
                        sguardPlusForSui
                } = option
                if (!sguardPlus) return
                return `
                        contract sGuardPlus {
                                constructor() internal {
                                        ${genModifierLock(sguardPlusForRen)}
                                        ${genSuiCtor(sguardPlusForSui)}
                                }
                                ${genMethod(sguardPlus)}
                                ${genModifier(sguardPlusForRen)}
                                ${genSui(sguardPlusForSui)}
                                
                        }
                `
        }
}