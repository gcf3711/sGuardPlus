pragma solidity >=0.4.11;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                uint256 c = a + b;
                                assert(c >= a);
                                return c;
                        }
function add_uint(uint a, uint b) internal pure returns (uint) {
                                uint c = a + b;
                                assert(c >= a);
                                return c;
                        }
function sub_uint(uint a, uint b) internal pure returns (uint) {
                                assert(b <= a);
                                return a - b;
                        }
function div_uint(uint a, uint b) internal pure returns (uint) {
                                uint c = a / b;
                                return c;
                        }
                                
                                
                                
                        }
                contract Owned  {
constructor ()   {
owner=msg.sender;
}

address  public   owner;
modifier onlyOwner {
if (msg.sender==owner)
_;

}
function changeOwner (address    _newOwner)  onlyOwner  {
owner=_newOwner;
}

function execute (address    _dst,uint    _value,bytes    _data)  onlyOwner  {
bool     __sent_result100 = _dst.call.value(_value)(_data);
require(__sent_result100);
}

}
contract Token  {
function transfer (address    ,uint    )   returns (bool    );
function balanceOf (address    )  constant returns (uint    );
}
contract TokenSender is sGuardPlus,Owned {
Token  public   token;
uint  public   totalToDistribute;
uint  public   next;
struct Transfer {
address     addr;
uint     amount;
}
Transfer [] public   transfers;
constructor (address    _token)   {
token=Token(_token);
}

uint   constant  D160 = 0x0010000000000000000000000000000000000000000;
function fill (uint []   data)  onlyOwner  {
if (next>0)
throw;
uint     acc;
uint     offset = transfers.length;
transfers.length=add_uint256(transfers.length, data.length);
for(uint     i = 0;i<data.length; i=add_uint(i, 1)){
address     addr = address (data[i]&(sub_uint(D160, 1)));
uint     amount = div_uint(data[i], D160);
transfers[add_uint(offset, i)].addr=addr;
transfers[add_uint(offset, i)].amount=amount;
acc=add_uint(acc, amount);
}

totalToDistribute=add_uint(totalToDistribute, acc);
}

function run ()  onlyOwner  {
if (transfers.length==0)
return ;

uint     mNext = next;
next=transfers.length;
if ((mNext==0)&&(token.balanceOf(this)!=totalToDistribute))
throw;
while ((mNext<transfers.length)&&(gas()>150000)){
uint     amount = transfers[mNext].amount;
address     addr = transfers[mNext].addr;
if (amount>0)
{
if ( ! token.transfer(addr, transfers[mNext].amount))
throw;
}

mNext ++ ;
}

next=mNext;
}

function hasTerminated ()  constant returns (bool    ){
if (transfers.length==0)
return false;

if (next<transfers.length)
return false;

return true;
}

function nTransfers ()  constant returns (uint    ){
return transfers.length;
}

function gas () internal constant returns (uint    _gas){
assembly{
_gas := gas
}
}

}
