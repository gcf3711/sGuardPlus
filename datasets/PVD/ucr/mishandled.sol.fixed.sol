pragma solidity ^0.4.0;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                
                                
                                
                                
                        }
                contract SendBack  {
mapping (address  => uint )    userBalances;
function withdrawBalance ()   {
uint     amountToWithdraw = userBalances[msg.sender];
userBalances[msg.sender]=0;
bool     __sent_result100 = msg.sender.send(amountToWithdraw);
require(__sent_result100);
}

}
