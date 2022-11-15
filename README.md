# sGuard+
## Introduction
sGuard+ is a automated vulnerability repair tool for Ethereum smart contracts written in the <a  href ="https://github.com/ethereum/solidity">Solidity</a> language.

## Features
sGuard+ supports 5 vulnerability types:
- <a  href ="https://swcregistry.io/docs/SWC-101">SWC-101</a>: Integer Overflow and Underflow Vulnerability (IOU)
- <a  href ="https://swcregistry.io/docs/SWC-104">SWC-104</a>: Unchecked Call Return Value Vulnerability (UCR)
- <a  href ="https://swcregistry.io/docs/SWC-106">SWC-106</a>: Unprotected SELFDESTRUCT Instruction Vulnerability (USI)
- <a  href ="https://swcregistry.io/docs/SWC-107">SWC-107</a>: Reentrancy Vulnerability (REN)
- <a  href ="https://swcregistry.io/docs/SWC-115">SWC-115</a>: Authorization through Tx-origin Vulnerability (TXO)


<!-- ## Docker
Use the --- docker image.
```bash
docker pull ---
```
To share a directory in the container:
```bash
docker run -it -v ---
``` -->

<!-- ## Install -->
## Prerequisites
Python (v3.8)

Nodejs (v16)

```bash
pip install -r requirements.txt
npm install
```

## Usage
```bash
solc-select install 0.4.26
solc-select use 0.4.26
cd src
node index.js ../example/motivation_example.sol
```
The repaired contract is 
```javascript
pragma solidity ^0.4.0;

contract sGuardPlus {
    constructor() internal {
        __lock_modifier0_lock = false;
    }

    function add_uint(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    bool private __lock_modifier0_lock;
    modifier __lock_modifier0() {
        require(!__lock_modifier0_lock);
        __lock_modifier0_lock = true;
        _;
        __lock_modifier0_lock = false;
    }
}

contract Reentrancy_bonus is sGuardPlus {
    mapping(address => uint256) private userBalances;
    mapping(address => bool) private claimedBonus;
    mapping(address => uint256) private rewardsForA;

    function withdrawReward(address recipient) public {
        uint256 amountToWithdraw = rewardsForA[recipient];
        rewardsForA[recipient] = 0;
        (bool success, ) = recipient.call.value(amountToWithdraw)("");
        require(success);
    }

    function getFirstWithdrawalBonus(address recipient)
        public
        __lock_modifier0
    {
        require(!claimedBonus[recipient]);
        rewardsForA[recipient] = add_uint(rewardsForA[recipient], 100);
        withdrawReward(recipient);
        claimedBonus[recipient] = true;
    }
}

```

## License
sGuard+ is licensed under the MIT license.

