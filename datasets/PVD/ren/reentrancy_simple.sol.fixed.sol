pragma solidity ^0.4.15;

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
                contract Reentrance is sGuardPlus {
mapping (address  => uint )    userBalance;
function getBalance (address    u)  constant returns (uint    ){
return userBalance[u];
}

function addToBalance ()  payable {
userBalance[msg.sender]+=msg.value;
}

function withdrawBalance ()  __lock_modifier0  {
if ( ! (msg.sender.call.value(userBalance[msg.sender])()))
{
throw;}

userBalance[msg.sender]=0;
}

}
