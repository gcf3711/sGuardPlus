pragma solidity 0.4.26;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                
                                
                                
                                
                        }
                contract ReturnValue  {
function callchecked (address    callee) public  {
require(callee.call());
}

function callnotchecked (address    callee) public  {
bool     __sent_result100 = callee.call();
require(__sent_result100);
}

}
