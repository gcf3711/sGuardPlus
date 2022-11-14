pragma solidity ^0.4.0;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint(uint a, uint b) internal pure returns (uint) {
                                uint c = a + b;
                                assert(c >= a);
                                return c;
                        }
                                
                                
                                
                        }
                contract TimeLock is sGuardPlus {
mapping (address  => uint ) public   balances;
mapping (address  => uint ) public   lockTime;
function deposit () public payable {
balances[msg.sender]+=msg.value;
lockTime[msg.sender]=now+1 weeks;
}

function increaseLockTime (uint    _secondsToIncrease) public  {
lockTime[msg.sender]=add_uint(lockTime[msg.sender], _secondsToIncrease);
}

function withdraw () public  {
require(balances[msg.sender]>0);
require(now>lockTime[msg.sender]);
uint     transferValue = balances[msg.sender];
balances[msg.sender]=0;
msg.sender.transfer(transferValue);
}

}
