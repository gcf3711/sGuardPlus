pragma solidity ^0.4.18;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function mul_uint(uint a, uint b) internal pure returns (uint) {
                                if (a == 0) {
                                        return 0;
                                }
                                uint c = a * b;
                                assert(c / a == b);
                                return c;
                        }
function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                uint256 c = a + b;
                                assert(c >= a);
                                return c;
                        }
                                
                                
                                
                        }
                contract Owned  {
address  public   owner;
constructor () public  {
owner=msg.sender;
}

modifier onlyOwner {
require(msg.sender==owner);
_;
}
function transferOwnership (address    newOwner) public onlyOwner  {
owner=newOwner;
}

}
contract GFCB is sGuardPlus,Owned {
string  public   name = "Golden Fortune Coin Blocked";
string  public   symbol = "GFCB";
uint8  public   decimals = 18;
uint256  public   totalSupply;
uint256  public   sellPrice;
uint256  public   buyPrice;
uint     minBalanceForAccounts;
mapping (address  => uint256 ) public   balanceOf;
mapping (address  => bool ) public   frozenAccount;
event Transfer (address  indexed  from,address  indexed  to,uint256    value);
event FrozenFunds (address    target,bool    frozen);
constructor () public  {
totalSupply=10000000000000000000000000000;
balanceOf[msg.sender]=totalSupply;
}

function setMinBalance (uint    minimumBalanceInFinney) public onlyOwner  {
minBalanceForAccounts=mul_uint(minimumBalanceInFinney, 1 finney);
}

function _transfer (address    _from,address    _to,uint    _value) internal  {
require(_to!=0x0);
require(balanceOf[_from]>=_value);
require(balanceOf[_to]+_value>balanceOf[_to]);
require( ! frozenAccount[_from]);
require( ! frozenAccount[_to]);
balanceOf[_from]-=_value;
balanceOf[_to]+=_value;
emit Transfer(_from, _to, _value);
}

function transfer (address    _to,uint256    _value) public  {
require( ! frozenAccount[msg.sender]);
if (msg.sender.balance<minBalanceForAccounts)
{
sell((minBalanceForAccounts-msg.sender.balance)/sellPrice);
}

_transfer(msg.sender, _to, _value);
}

function mintToken (address    target,uint256    mintedAmount) public onlyOwner  {
balanceOf[target]=add_uint256(balanceOf[target], mintedAmount);
totalSupply=add_uint256(totalSupply, mintedAmount);
emit Transfer(0, owner, mintedAmount);
emit Transfer(owner, target, mintedAmount);
}

function freezeAccount (address    target,bool    freeze) public onlyOwner  {
frozenAccount[target]=freeze;
emit FrozenFunds(target, freeze);
}

function setPrices (uint256    newSellPrice,uint256    newBuyPrice) public onlyOwner  {
sellPrice=newSellPrice;
buyPrice=newBuyPrice;
}

function buy () public payable returns (uint    amount){
amount=msg.value/buyPrice;
require(balanceOf[this]>=amount);
balanceOf[msg.sender]+=amount;
balanceOf[this]-=amount;
emit Transfer(this, msg.sender, amount);
return amount;
}

function sell (uint    amount) public  returns (uint    revenue){
require(balanceOf[msg.sender]>=amount);
balanceOf[this]+=amount;
balanceOf[msg.sender]-=amount;
revenue=amount*sellPrice;
msg.sender.transfer(revenue);
emit Transfer(msg.sender, this, amount);
return revenue;
}

}
