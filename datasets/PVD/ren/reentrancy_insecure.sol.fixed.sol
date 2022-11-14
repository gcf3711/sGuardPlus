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
                contract Reentrancy_insecure is sGuardPlus {
mapping (address  => uint ) private   userBalances;
function withdrawBalance () public __lock_modifier0  {
uint     amountToWithdraw = userBalances[msg.sender];
(bool     success, ) = msg.sender.call.value(amountToWithdraw)("");
require(success);
userBalances[msg.sender]=0;
}

}
