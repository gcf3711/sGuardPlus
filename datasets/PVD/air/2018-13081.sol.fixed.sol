pragma solidity ^0.4.2;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                uint256 c = a + b;
                                assert(c >= a);
                                return c;
                        }
function mul_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                if (a == 0) {
                                        return 0;
                                }
                                uint256 c = a * b;
                                assert(c / a == b);
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
contract tokenRecipient  {
function receiveApproval (address    _from,uint256    _value,address    _token,bytes    _extraData)   ;
}
contract token  {
string  public   standard = "Token 0.1";
string  public   name;
string  public   symbol;
uint8  public   decimals;
uint256  public   totalSupply;
mapping (address  => uint256 ) public   balanceOf;
mapping (address  => mapping (address  => uint256 )) public   allowance;
event Transfer (address  indexed  from,address  indexed  to,uint256    value);
constructor (uint256    initialSupply,string    tokenName,uint8    decimalUnits,string    tokenSymbol)   {
balanceOf[msg.sender]=initialSupply;
totalSupply=initialSupply;
name=tokenName;
symbol=tokenSymbol;
decimals=decimalUnits;
}

function transfer (address    _to,uint256    _value)   {
if (balanceOf[msg.sender]<_value)
throw;
if (balanceOf[_to]+_value<balanceOf[_to])
throw;
balanceOf[msg.sender]-=_value;
balanceOf[_to]+=_value;
Transfer(msg.sender, _to, _value);
}

function approve (address    _spender,uint256    _value)   returns (bool    success){
allowance[msg.sender][_spender]=_value;
return true;
}

function approveAndCall (address    _spender,uint256    _value,bytes    _extraData)   returns (bool    success){
tokenRecipient     spender = tokenRecipient(_spender);
if (approve(_spender, _value))
{
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}

}

function transferFrom (address    _from,address    _to,uint256    _value)   returns (bool    success){
if (balanceOf[_from]<_value)
throw;
if (balanceOf[_to]+_value<balanceOf[_to])
throw;
if (_value>allowance[_from][msg.sender])
throw;
balanceOf[_from]-=_value;
balanceOf[_to]+=_value;
allowance[_from][msg.sender]-=_value;
Transfer(_from, _to, _value);
return true;
}

function ()   {
throw;}

}
contract GZSToken is sGuardPlus,owned,token {
uint  public   buyRate = 46000;
bool  public   isSelling = true;
mapping (address  => bool ) public   frozenAccount;
event FrozenFunds (address    target,bool    frozen);
constructor (uint256    initialSupply,string    tokenName,uint8    decimalUnits,string    tokenSymbol)  token(initialSupply, tokenName, decimalUnits, tokenSymbol)  {
}

function transfer (address    _to,uint256    _value)   {
if (balanceOf[msg.sender]<_value)
throw;
if (balanceOf[_to]+_value<balanceOf[_to])
throw;
if (frozenAccount[msg.sender])
throw;
balanceOf[msg.sender]-=_value;
balanceOf[_to]+=_value;
Transfer(msg.sender, _to, _value);
}

function transferFrom (address    _from,address    _to,uint256    _value)   returns (bool    success){
if (frozenAccount[_from])
throw;
if (balanceOf[_from]<_value)
throw;
if (balanceOf[_to]+_value<balanceOf[_to])
throw;
if (_value>allowance[_from][msg.sender])
throw;
balanceOf[_from]-=_value;
balanceOf[_to]+=_value;
allowance[_from][msg.sender]-=_value;
Transfer(_from, _to, _value);
return true;
}

function mintToken (address    target,uint256    mintedAmount)  onlyOwner  {
balanceOf[target]=add_uint256(balanceOf[target], mintedAmount);
totalSupply=add_uint256(totalSupply, mintedAmount);
Transfer(0, this, mintedAmount);
Transfer(this, target, mintedAmount);
}

function freezeAccount (address    target,bool    freeze)  onlyOwner  {
frozenAccount[target]=freeze;
FrozenFunds(target, freeze);
}

function setBuyRate (uint    newBuyRate)  onlyOwner  {
buyRate=newBuyRate;
}

function setSelling (bool    newStatus)  onlyOwner  {
isSelling=newStatus;
}

function buy ()  payable {
if (isSelling==false)
throw;
uint     amount = mul_uint256(msg.value, buyRate);
balanceOf[msg.sender]=add_uint(balanceOf[msg.sender], amount);
balanceOf[this]=sub_uint(balanceOf[this], amount);
Transfer(this, msg.sender, amount);
}

function withdrawToOwner (uint256    amountWei)  onlyOwner  {
owner.transfer(amountWei);
}

}
