pragma solidity ^0.4.10;

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
function sub_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                assert(b <= a);
                                return a - b;
                        }
                                
                                
                                
                        }
                contract ForeignToken  {
function balanceOf (address    _owner)  constant returns (uint256    );
function transfer (address    _to,uint256    _value)   returns (bool    );
}
contract UselessEthereumToken is sGuardPlus {
address     owner = msg.sender;
bool  public   purchasingAllowed = false;
mapping (address  => uint256 )    balances;
mapping (address  => mapping (address  => uint256 ))    allowed;
uint256  public   totalContribution = 0;
uint256  public   totalBonusTokensIssued = 0;
uint256  public   totalSupply = 0;
function name ()  constant returns (string    ){
return "Useless Ethereum Token";
}

function symbol ()  constant returns (string    ){
return "UET";
}

function decimals ()  constant returns (uint8    ){
return 18;
}

function balanceOf (address    _owner)  constant returns (uint256    ){
return balances[_owner];
}

function transfer (address    _to,uint256    _value)   returns (bool    success){
if (msg.data.length<(2*32)+4)
{
throw;}

if (_value==0)
{
return false;
}

uint256     fromBalance = balances[msg.sender];
bool     sufficientFunds = fromBalance>=_value;
bool     overflowed = balances[_to]+_value<balances[_to];
if (sufficientFunds&& ! overflowed)
{
balances[msg.sender]-=_value;
balances[_to]+=_value;
Transfer(msg.sender, _to, _value);
return true;
}
 else 
{
return false;
}

}

function transferFrom (address    _from,address    _to,uint256    _value)   returns (bool    success){
if (msg.data.length<add_uint256((mul_uint256(3, 32)), 4))
{
throw;}

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

event Transfer (address  indexed  _from,address  indexed  _to,uint256    _value);
event Approval (address  indexed  _owner,address  indexed  _spender,uint256    _value);
function enablePurchasing ()   {
if (msg.sender!=owner)
{
throw;}

purchasingAllowed=true;
}

function disablePurchasing ()   {
if (msg.sender!=owner)
{
throw;}

purchasingAllowed=false;
}

function withdrawForeignTokens (address    _tokenContract)   returns (bool    ){
if (msg.sender!=owner)
{
throw;}

ForeignToken     token = ForeignToken(_tokenContract);
uint256     amount = token.balanceOf(address (this));
return token.transfer(owner, amount);
}

function getStats ()  constant returns (uint256    ,uint256    ,uint256    ,bool    ){
return (totalContribution, totalSupply, totalBonusTokensIssued, purchasingAllowed);
}

function ()  payable {
if ( ! purchasingAllowed)
{
throw;}

if (msg.value==0)
{
return ;
}

owner.transfer(msg.value);
totalContribution=add_uint256(totalContribution, msg.value);
uint256     tokensIssued = (mul_uint256(msg.value, 100));
if (msg.value>=10 finney)
{
tokensIssued=add_uint256(tokensIssued, totalContribution);
bytes20     bonusHash = ripemd160(block.coinbase, block.number, block.timestamp);
if (bonusHash[0]==0)
{
uint8     bonusMultiplier = ((bonusHash[1]&0x01!=0) ? 1 : 0)+((bonusHash[1]&0x02!=0) ? 1 : 0)+((bonusHash[1]&0x04!=0) ? 1 : 0)+((bonusHash[1]&0x08!=0) ? 1 : 0)+((bonusHash[1]&0x10!=0) ? 1 : 0)+((bonusHash[1]&0x20!=0) ? 1 : 0)+((bonusHash[1]&0x40!=0) ? 1 : 0)+((bonusHash[1]&0x80!=0) ? 1 : 0);
uint256     bonusTokensIssued = mul_uint256((mul_uint256(msg.value, 100)), bonusMultiplier);
tokensIssued=add_uint256(tokensIssued, bonusTokensIssued);
totalBonusTokensIssued=add_uint256(totalBonusTokensIssued, bonusTokensIssued);
}

}

totalSupply=add_uint256(totalSupply, tokensIssued);
balances[msg.sender]=add_uint256(balances[msg.sender], tokensIssued);
Transfer(address (this), msg.sender, tokensIssued);
}

}
