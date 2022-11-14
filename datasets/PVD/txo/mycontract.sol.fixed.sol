pragma solidity 0.4.26;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                
                                
                                
                                
                        }
                contract MyContract  {
address     owner;
constructor () public  {
owner=msg.sender;
}

function sendTo (address    receiver,uint    amount) public  {
require(msg.sender==owner);
receiver.transfer(amount);
}

}
