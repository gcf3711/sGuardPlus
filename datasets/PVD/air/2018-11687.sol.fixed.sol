pragma solidity ^0.4.13;

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
function mul_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                if (a == 0) {
                                        return 0;
                                }
                                uint256 c = a * b;
                                assert(c / a == b);
                                return c;
                        }
function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                uint256 c = a + b;
                                assert(c >= a);
                                return c;
                        }
function pow_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                uint256 c = 1;
                                for(uint256 i = 0; i < b; i = add_uint256(i, 1)){
                                        c = mul_uint256(c, a);
                                }
                                return c;
                        }
                                
                                
                                
                        }
                contract ERC20  {
function totalSupply ()  constant returns (uint256    totalSupply);
function balanceOf (address    _owner)  constant returns (uint256    balance);
function transfer (address    _to,uint256    _value)   returns (bool    success);
function transferFrom (address    _from,address    _to,uint256    _value)   returns (bool    success);
function approve (address    _spender,uint256    _value)   returns (bool    success);
function allowance (address    _owner,address    _spender)  constant returns (uint256    remaining);
event Transfer (address  indexed  _from,address  indexed  _to,uint256    _value);
event Approval (address  indexed  _owner,address  indexed  _spender,uint256    _value);
}
contract BitcoinRed is sGuardPlus,ERC20 {
string  public constant  symbol = "BTCR";
string  public constant  name = "Bitcoin Red";
uint8  public constant  decimals = 8;
uint256     _totalSupply = 21000000*10**8;
address  public   owner;
mapping (address  => uint256 )    balances;
mapping (address  => mapping (address  => uint256 ))    allowed;
constructor ()   {
owner=msg.sender;
balances[owner]=21000000*10**8;
}

modifier onlyOwner (){
require(msg.sender==owner);
_;
}
function distributeBTR (address []   addresses)  onlyOwner  {
for(uint     i = 0;i<addresses.length; i=add_uint(i, 1)){
balances[owner]=sub_uint256(balances[owner], mul_uint256(2000, pow_uint256(10, 8)));
balances[addresses[i]]=add_uint256(balances[addresses[i]], mul_uint256(2000, pow_uint256(10, 8)));
Transfer(owner, addresses[i], mul_uint256(2000, pow_uint256(10, 8)));
}

}

function totalSupply ()  constant returns (uint256    totalSupply){
totalSupply=_totalSupply;
}

function balanceOf (address    _owner)  constant returns (uint256    balance){
return balances[_owner];
}

function transfer (address    _to,uint256    _amount)   returns (bool    success){
if (balances[msg.sender]>=_amount&&_amount>0&&add_uint256(balances[_to], _amount)>balances[_to])
{
balances[msg.sender]=sub_uint256(balances[msg.sender], _amount);
balances[_to]=add_uint256(balances[_to], _amount);
Transfer(msg.sender, _to, _amount);
return true;
}
 else 
{
return false;
}

}

function transferFrom (address    _from,address    _to,uint256    _amount)   returns (bool    success){
if (balances[_from]>=_amount&&allowed[_from][msg.sender]>=_amount&&_amount>0&&balances[_to]+_amount>balances[_to])
{
balances[_from]-=_amount;
allowed[_from][msg.sender]-=_amount;
balances[_to]+=_amount;
Transfer(_from, _to, _amount);
return true;
}
 else 
{
return false;
}

}

function approve (address    _spender,uint256    _amount)   returns (bool    success){
allowed[msg.sender][_spender]=_amount;
Approval(msg.sender, _spender, _amount);
return true;
}

function allowance (address    _owner,address    _spender)  constant returns (uint256    remaining){
return allowed[_owner][_spender];
}

}
