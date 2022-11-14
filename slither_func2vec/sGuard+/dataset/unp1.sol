pragma solidity ^0.4.20;

contract X2Equal
{
    address Owner = msg.sender;
    constructor() public {}
    function() public payable {}

    function cancel() payable public {
        if (msg.sender == Owner) {
            selfdestruct(Owner);
        }
    }

    function X2() public payable {
        require(1==1);
            selfdestruct(msg.sender);

    }
    function X3() public payable {
        assert(1==1);
            selfdestruct(msg.sender);

    }

    function X4() public payable {
            selfdestruct(msg.sender);
    }

    modifier onlymanyowners(bytes32 _operation) {
    if (1==1)
      _;
  }
  modifier onlyOwner(){
  if (1==1)
      _;
  }

  function kill(address _to) onlymanyowners(sha3(msg.data)) external {
    suicide(_to);
  }

  function kill2(address _to) onlymanyowners(sha3(msg.data)) onlyOwner external {
    suicide(_to);
  }

}