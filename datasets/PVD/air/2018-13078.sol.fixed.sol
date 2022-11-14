pragma solidity ^0.4.2;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                uint256 c = a + b;
                                assert(c >= a);
                                return c;
                        }
                                
                                
                                
                        }
                contract owned  {
address  public   owner;
constructor () public  {
owner=msg.sender;
}

modifier onlyOwner {
if (msg.sender!=owner)
revert();

_;
}
function transferOwnership (address    newOwner) public onlyOwner  {
owner=newOwner;
}

}
contract tokenRecipient  {
function receiveApproval (address    _from,uint256    _value,address    _token,bytes    _extraData) public  ;
}
contract token  {
string  public   name;
string  public   symbol;
uint8  public   decimals;
uint256  public   totalSupply;
mapping (address  => uint256 ) public   balanceOf;
mapping (address  => mapping (address  => uint256 )) public   allowance;
event Transfer (address  indexed  from,address  indexed  to,uint256    value);
constructor (uint256    initialSupply,string    tokenName,uint8    decimalUnits,string    tokenSymbol) public  {
balanceOf[msg.sender]=initialSupply;
totalSupply=initialSupply;
name=tokenName;
symbol=tokenSymbol;
decimals=decimalUnits;
}

function transfer (address    _to,uint256    _value) public  {
if (balanceOf[msg.sender]<_value)
revert();

if (balanceOf[_to]+_value<balanceOf[_to])
revert();

balanceOf[msg.sender]-=_value;
balanceOf[_to]+=_value;
Transfer(msg.sender, _to, _value);
}

function approve (address    _spender,uint256    _value) public  returns (bool    success){
allowance[msg.sender][_spender]=_value;
return true;
}

function approveAndCall (address    _spender,uint256    _value,bytes    _extraData) public  returns (bool    success){
tokenRecipient     spender = tokenRecipient(_spender);
if (approve(_spender, _value))
{
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}

}

function transferFrom (address    _from,address    _to,uint256    _value) public  returns (bool    success){
if (balanceOf[_from]<_value)
revert();

if (balanceOf[_to]+_value<balanceOf[_to])
revert();

if (_value>allowance[_from][msg.sender])
revert();

balanceOf[_from]-=_value;
balanceOf[_to]+=_value;
allowance[_from][msg.sender]-=_value;
Transfer(_from, _to, _value);
return true;
}

function () public  {
revert();
}

}
contract Jitech is sGuardPlus,owned,token {
mapping (address  => bool ) public   frozenAccount;
event FrozenFunds (address    target,bool    frozen);
constructor (uint256    initialSupply,string    tokenName,uint8    decimalUnits,string    tokenSymbol) public token(initialSupply, tokenName, decimalUnits, tokenSymbol)  {
}

function transfer (address    _to,uint256    _value) public  {
if (balanceOf[msg.sender]<_value)
revert();

if (balanceOf[_to]+_value<balanceOf[_to])
revert();

if (frozenAccount[msg.sender])
revert();

balanceOf[msg.sender]-=_value;
balanceOf[_to]+=_value;
Transfer(msg.sender, _to, _value);
}

function transferFrom (address    _from,address    _to,uint256    _value) public  returns (bool    success){
if (frozenAccount[_from])
revert();

if (balanceOf[_from]<_value)
revert();

if (balanceOf[_to]+_value<balanceOf[_to])
revert();

if (_value>allowance[_from][msg.sender])
revert();

balanceOf[_from]-=_value;
balanceOf[_to]+=_value;
allowance[_from][msg.sender]-=_value;
Transfer(_from, _to, _value);
return true;
}

function mintToken (address    target,uint256    mintedAmount) public onlyOwner  {
balanceOf[target]=add_uint256(balanceOf[target], mintedAmount);
Transfer(0, owner, mintedAmount);
Transfer(owner, target, mintedAmount);
}

function freezeAccount (address    target,bool    freeze) public onlyOwner  {
frozenAccount[target]=freeze;
FrozenFunds(target, freeze);
}

}
