
                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                uint256 c = a + b;
                                assert(c >= a);
                                return c;
                        }
function mul_uint(uint a, uint b) internal pure returns (uint) {
                                if (a == 0) {
                                        return 0;
                                }
                                uint c = a * b;
                                assert(c / a == b);
                                return c;
                        }
                                
                                
                                
                        }
                contract owned  {
address  public   owner;
constructor ()   {
owner=msg.sender;
}

modifier onlyOwner {
if (msg.sender!=owner)
throw;
_;
}
function transferOwnership (address    newOwner)  onlyOwner  {
owner=newOwner;
}

}
contract MyToken is sGuardPlus,owned {
string  public   standard = "Token 0.1";
string  public   name;
string  public   symbol;
uint8  public   decimals;
uint256  public   totalSupply;
uint256  public   sellPrice;
uint256  public   buyPrice;
uint     minBalanceForAccounts;
mapping (address  => uint256 ) public   balanceOf;
mapping (address  => bool ) public   frozenAccount;
event Transfer (address  indexed  from,address  indexed  to,uint256    value);
event FrozenFunds (address    target,bool    frozen);
constructor (uint256    initialSupply,string    tokenName,uint8    decimalUnits,string    tokenSymbol,address    centralMinter)   {
if (centralMinter!=0)
owner=msg.sender;

balanceOf[msg.sender]=initialSupply;
totalSupply=initialSupply;
name=tokenName;
symbol=tokenSymbol;
decimals=decimalUnits;
}

function transfer (address    _to,uint256    _value)   {
if (frozenAccount[msg.sender])
throw;
if (balanceOf[msg.sender]<_value)
throw;
if (balanceOf[_to]+_value<balanceOf[_to])
throw;
if (msg.sender.balance<minBalanceForAccounts)
sell((minBalanceForAccounts-msg.sender.balance)/sellPrice);

if (_to.balance<minBalanceForAccounts)
{
bool     __sent_result100 = _to.send(sell((minBalanceForAccounts-_to.balance)/sellPrice));
require(__sent_result100);
}

balanceOf[msg.sender]-=_value;
balanceOf[_to]+=_value;
Transfer(msg.sender, _to, _value);
}

function mintToken (address    target,uint256    mintedAmount)  onlyOwner  {
balanceOf[target]=add_uint256(balanceOf[target], mintedAmount);
totalSupply=add_uint256(totalSupply, mintedAmount);
Transfer(0, owner, mintedAmount);
Transfer(owner, target, mintedAmount);
}

function freezeAccount (address    target,bool    freeze)  onlyOwner  {
frozenAccount[target]=freeze;
FrozenFunds(target, freeze);
}

function setPrices (uint256    newSellPrice,uint256    newBuyPrice)  onlyOwner  {
sellPrice=newSellPrice;
buyPrice=newBuyPrice;
}

function buy ()   returns (uint    amount){
amount=msg.value/buyPrice;
if (balanceOf[this]<amount)
throw;
balanceOf[msg.sender]+=amount;
balanceOf[this]-=amount;
Transfer(this, msg.sender, amount);
return amount;
}

function sell (uint    amount)   returns (uint    revenue){
if (balanceOf[msg.sender]<amount)
throw;
balanceOf[this]+=amount;
balanceOf[msg.sender]-=amount;
revenue=amount*sellPrice;
bool     __sent_result101 = msg.sender.send(revenue);
require(__sent_result101);
Transfer(msg.sender, this, amount);
return revenue;
}

function setMinBalance (uint    minimumBalanceInFinney)  onlyOwner  {
minBalanceForAccounts=mul_uint(minimumBalanceInFinney, 1 finney);
}

}
