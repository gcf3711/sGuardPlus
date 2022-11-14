pragma solidity ^0.4.0;

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
                contract EtherBank is sGuardPlus {
mapping (address  => uint )    userBalances;
function getBalance (address    user)  constant returns (uint    ){
return userBalances[user];
}

function addToBalance ()   {
userBalances[msg.sender]+=msg.value;
}

function withdrawBalance ()  __lock_modifier0  {
uint     amountToWithdraw = userBalances[msg.sender];
if ( ! (msg.sender.call.value(amountToWithdraw)()))
{
throw;}

userBalances[msg.sender]=0;
}

}
