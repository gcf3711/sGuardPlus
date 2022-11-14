pragma solidity ^0.4.19;

                        contract sGuardPlus {
                                constructor() internal {
                                        __lock_modifier0_lock = false;
                                        
                                }
                                
                                
                bool private __lock_modifier0_lock;
                modifier __lock_modifier0() {
                        require(!__lock_modifier0_lock);
                        __lock_modifier0_lock = true;
                        _;
                        __lock_modifier0_lock = false;
                        
                }
                
                                
                                
                        }
                contract ReentrancyDAO is sGuardPlus {
mapping (address  => uint )    credit;
uint     balance;
function withdrawAll () public __lock_modifier0  {
uint     oCredit = credit[msg.sender];
if (oCredit>0)
{
balance-=oCredit;
bool     callResult = msg.sender.call.value(oCredit)();
require(callResult);
credit[msg.sender]=0;
}

}

function deposit () public payable {
credit[msg.sender]+=msg.value;
balance+=msg.value;
}

}
