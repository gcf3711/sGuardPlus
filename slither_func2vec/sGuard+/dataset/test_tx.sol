pragma solidity 0.4.26;
contract TX{
  address owner;
  modifier onlyOwner() {
  require(tx.origin==owner);
  _;
  }
modifier onlyOwner_() {
  address a = tx.origin;
  require(a==owner);
  _;
  }
  modifier onlyMsg(){
    address a = tx.origin;
    address b = msg.sender;
    require(a==b);
    _;
  }
  modifier onlyMsg_(){
    require(tx.origin==msg.sender);
    _;
  }
  function T1() public onlyOwner{
      msg.sender.call.value(1)("");
  }
  function T2() public onlyOwner_{
      msg.sender.call.value(1)("");
  }
  function T3() public onlyMsg{
      msg.sender.call.value(1)("");
  }
  function T4() public onlyMsg_{
      msg.sender.call.value(1)("");
  }
}