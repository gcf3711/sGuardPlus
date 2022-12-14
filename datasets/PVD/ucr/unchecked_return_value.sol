/* @Labeled: [11] */
pragma solidity 0.4.26;

contract ReturnValue {

  function callchecked(address callee) public {
  	require(callee.call());
  }

  function callnotchecked(address callee) public {
    callee.call();
  }
}
