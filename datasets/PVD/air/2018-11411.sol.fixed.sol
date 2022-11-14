pragma solidity ^0.4.16;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint(uint a, uint b) internal pure returns (uint) {
                                uint c = a + b;
                                assert(c >= a);
                                return c;
                        }
function sub_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                assert(b <= a);
                                return a - b;
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
                                
                                
                                
                        }
                contract ForeignToken  {
function balanceOf (address    _owner)  constant returns (uint256    );
function transfer (address    _to,uint256    _value)   returns (bool    );
}
contract DimonCoin is sGuardPlus {
address     owner = msg.sender;
mapping (address  => uint256 )    balances;
mapping (address  => mapping (address  => uint256 ))    allowed;
uint256  public   totalSupply = 100000000*10**8;
function name ()  constant returns (string    ){
return "DimonCoin";
}

function symbol ()  constant returns (string    ){
return "FUD";
}

function decimals ()  constant returns (uint8    ){
return 8;
}

event Transfer (address  indexed  _from,address  indexed  _to,uint256    _value);
event Approval (address  indexed  _owner,address  indexed  _spender,uint256    _value);
constructor ()   {
owner=msg.sender;
balances[msg.sender]=totalSupply;
}

modifier onlyOwner {
require(msg.sender==owner);
_;
}
function transferOwnership (address    newOwner)  onlyOwner  {
owner=newOwner;
}

function getEthBalance (address    _addr)  constant returns (uint    ){
return _addr.balance;
}

function distributeFUD (address []   addresses,uint256    _value,uint256    _ethbal)  onlyOwner  {
for(uint     i = 0;i<addresses.length; i=add_uint(i, 1)){
if (getEthBalance(addresses[i])<_ethbal)
{
continue;
}

balances[owner]=sub_uint256(balances[owner], _value);
balances[addresses[i]]=add_uint256(balances[addresses[i]], _value);
Transfer(owner, addresses[i], _value);
}

}

function balanceOf (address    _owner)  constant returns (uint256    ){
return balances[_owner];
}

modifier onlyPayloadSize (uint    size){
assert(msg.data.length>=size+4);
_;
}
function transfer (address    _to,uint256    _value)  onlyPayloadSize(mul_uint256(2, 32))  returns (bool    success){
if (_value==0)
{
return false;
}

uint256     fromBalance = balances[msg.sender];
bool     sufficientFunds = fromBalance>=_value;
bool     overflowed = add_uint256(balances[_to], _value)<balances[_to];
if (sufficientFunds&& ! overflowed)
{
balances[msg.sender]=sub_uint256(balances[msg.sender], _value);
balances[_to]=add_uint256(balances[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
}
 else 
{
return false;
}

}

function transferFrom (address    _from,address    _to,uint256    _value)  onlyPayloadSize(mul_uint256(2, 32))  returns (bool    success){
if (_value==0)
{
return false;
}

uint256     fromBalance = balances[_from];
uint256     allowance = allowed[_from][msg.sender];
bool     sufficientFunds = fromBalance<=_value;
bool     sufficientAllowance = allowance<=_value;
bool     overflowed = add_uint256(balances[_to], _value)>balances[_to];
if (sufficientFunds&&sufficientAllowance&& ! overflowed)
{
balances[_to]=add_uint256(balances[_to], _value);
balances[_from]=sub_uint256(balances[_from], _value);
allowed[_from][msg.sender]=sub_uint256(allowed[_from][msg.sender], _value);
Transfer(_from, _to, _value);
return true;
}
 else 
{
return false;
}

}

function approve (address    _spender,uint256    _value)   returns (bool    success){
if (_value!=0&&allowed[msg.sender][_spender]!=0)
{
return false;
}

allowed[msg.sender][_spender]=_value;
Approval(msg.sender, _spender, _value);
return true;
}

function allowance (address    _owner,address    _spender)  constant returns (uint256    ){
return allowed[_owner][_spender];
}

function withdrawForeignTokens (address    _tokenContract)   returns (bool    ){
require(msg.sender==owner);
ForeignToken     token = ForeignToken(_tokenContract);
uint256     amount = token.balanceOf(address (this));
return token.transfer(owner, amount);
}

}
