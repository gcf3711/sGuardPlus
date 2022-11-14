pragma solidity ^0.4.18;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                
                                
                                
                                
                        }
                contract Lotto  {
bool  public   payedOut = false;
address  public   winner;
uint  public   winAmount;
function sendToWinner () public  {
require( ! payedOut);
bool     __sent_result100 = winner.send(winAmount);
require(__sent_result100);
payedOut=true;
}

function withdrawLeftOver () public  {
require(payedOut);
bool     __sent_result101 = msg.sender.send(this.balance);
require(__sent_result101);
}

}
