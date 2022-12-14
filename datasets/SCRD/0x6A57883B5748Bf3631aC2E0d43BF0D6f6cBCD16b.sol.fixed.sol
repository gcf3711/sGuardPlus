pragma solidity ^0.4.12;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                
                                
                                
                                
                        }
                contract SafeMath  {
function safeMul (uint256    a,uint256    b) internal constant returns (uint256    ){
uint256     c = a*b;
assert(a==0||c/a==b);
return c;
}

function safeDiv (uint256    a,uint256    b) internal constant returns (uint256    ){
uint256     c = a/b;
return c;
}

function safeSub (uint256    a,uint256    b) internal constant returns (uint256    ){
assert(b<=a);
return a-b;
}

function safeAdd (uint256    a,uint256    b) internal constant returns (uint256    ){
uint256     c = a+b;
assert(c>=a);
return c;
}

function max64 (uint64    a,uint64    b) internal constant returns (uint64    ){
return a>=b ? a : b;
}

function min64 (uint64    a,uint64    b) internal constant returns (uint64    ){
return a<b ? a : b;
}

function max256 (uint256    a,uint256    b) internal constant returns (uint256    ){
return a>=b ? a : b;
}

function min256 (uint256    a,uint256    b) internal constant returns (uint256    ){
return a<b ? a : b;
}

}
contract ERC20  {
uint256  public   totalSupply;
function balanceOf (address    who)  constant returns (uint256    );
function transfer (address    to,uint256    value)   returns (bool    );
event Transfer (address  indexed  from,address  indexed  to,uint256    value);
function allowance (address    owner,address    spender)  constant returns (uint256    );
function transferFrom (address    from,address    to,uint256    value)   returns (bool    );
function approve (address    spender,uint256    value)   returns (bool    );
event Approval (address  indexed  owner,address  indexed  spender,uint256    value);
}
contract StandardToken is ERC20,SafeMath {
event Minted (address    receiver,uint256    amount);
mapping (address  => uint256 )    balances;
mapping (address  => mapping (address  => uint256 ))    allowed;
modifier onlyPayloadSize (uint256    size){
if (msg.data.length!=size+4)
{
throw;}

_;
}
function transfer (address    _to,uint256    _value)  onlyPayloadSize(2*32)  returns (bool    success){
balances[msg.sender]=safeSub(balances[msg.sender], _value);
balances[_to]=safeAdd(balances[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
}

function transferFrom (address    _from,address    _to,uint256    _value)   returns (bool    success){
uint256     _allowance = allowed[_from][msg.sender];
balances[_to]=safeAdd(balances[_to], _value);
balances[_from]=safeSub(balances[_from], _value);
allowed[_from][msg.sender]=safeSub(_allowance, _value);
Transfer(_from, _to, _value);
return true;
}

function balanceOf (address    _owner)  constant returns (uint256    balance){
return balances[_owner];
}

function approve (address    _spender,uint256    _value)   returns (bool    success){
if ((_value!=0)&&(allowed[msg.sender][_spender]!=0))
throw;
allowed[msg.sender][_spender]=_value;
Approval(msg.sender, _spender, _value);
return true;
}

function allowance (address    _owner,address    _spender)  constant returns (uint256    remaining){
return allowed[_owner][_spender];
}

function addApproval (address    _spender,uint256    _addedValue)  onlyPayloadSize(2*32)  returns (bool    success){
uint256     oldValue = allowed[msg.sender][_spender];
allowed[msg.sender][_spender]=safeAdd(oldValue, _addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}

function subApproval (address    _spender,uint256    _subtractedValue)  onlyPayloadSize(2*32)  returns (bool    success){
uint256     oldVal = allowed[msg.sender][_spender];
if (_subtractedValue>oldVal)
{
allowed[msg.sender][_spender]=0;
}
 else 
{
allowed[msg.sender][_spender]=safeSub(oldVal, _subtractedValue);
}

Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}

}
contract BurnableToken is StandardToken {
address  public constant  BURN_ADDRESS = 0;
event Burned (address    burner,uint256    burnedAmount);
function burn (uint256    burnAmount)   {
address     burner = msg.sender;
balances[burner]=safeSub(balances[burner], burnAmount);
totalSupply=safeSub(totalSupply, burnAmount);
Burned(burner, burnAmount);
}

}
contract UpgradeAgent  {
uint256  public   originalSupply;
function isUpgradeAgent () public constant returns (bool    ){
return true;
}

function upgradeFrom (address    _from,uint256    _value) public  ;
}
contract UpgradeableToken is StandardToken {
address  public   upgradeMaster;
UpgradeAgent  public   upgradeAgent;
uint256  public   totalUpgraded;
enum UpgradeState {
Unknown, 
NotAllowed, 
WaitingForAgent, 
ReadyToUpgrade, 
Upgrading
}
event Upgrade (address  indexed  _from,address  indexed  _to,uint256    _value);
event UpgradeAgentSet (address    agent);
constructor (address    _upgradeMaster)   {
upgradeMaster=_upgradeMaster;
}

function upgrade (uint256    value) public  {
UpgradeState     state = getUpgradeState();
if ( ! (state==UpgradeState.ReadyToUpgrade||state==UpgradeState.Upgrading))
{
throw;}

if (value==0)
throw;
balances[msg.sender]=safeSub(balances[msg.sender], value);
totalSupply=safeSub(totalSupply, value);
totalUpgraded=safeAdd(totalUpgraded, value);
upgradeAgent.upgradeFrom(msg.sender, value);
Upgrade(msg.sender, upgradeAgent, value);
}

function setUpgradeAgent (address    agent) external  {
if ( ! canUpgrade())
{
throw;}

if (agent==0x0)
throw;
if (msg.sender!=upgradeMaster)
throw;
if (getUpgradeState()==UpgradeState.Upgrading)
throw;
upgradeAgent=UpgradeAgent(agent);
if ( ! upgradeAgent.isUpgradeAgent())
throw;
if (upgradeAgent.originalSupply()!=totalSupply)
throw;
UpgradeAgentSet(upgradeAgent);
}

function getUpgradeState () public constant returns (UpgradeState    ){
if ( ! canUpgrade())
return UpgradeState.NotAllowed;
 else 
if (address (upgradeAgent)==0x00)
return UpgradeState.WaitingForAgent;
 else 
if (totalUpgraded==0)
return UpgradeState.ReadyToUpgrade;
 else 
return UpgradeState.Upgrading;



}

function setUpgradeMaster (address    master) public  {
if (master==0x0)
throw;
if (msg.sender!=upgradeMaster)
throw;
upgradeMaster=master;
}

function canUpgrade () public constant returns (bool    ){
return true;
}

}
contract Lescoin is BurnableToken,UpgradeableToken {
string  public   name;
string  public   symbol;
uint256  public   decimals;
constructor (address    _owner,address    _init)  UpgradeableToken(_owner)  {
name="Lescoin";
symbol="LSC";
totalSupply=200000000000000;
decimals=8;
balances[_init]=totalSupply;
}

}
contract LescoinPreSale  {
address  public   beneficiary;
address  public   coldWallet;
uint256  public   ethPrice;
uint256  public   bonus;
uint256  public   amountRaised;
Lescoin  public   tokenReward;
uint256  public constant  price = 50;
uint256  public constant  minSaleAmount = 10000;
constructor (address    _beneficiary,address    _coldWallet,uint256    _ethPrice,uint256    _bonus,Lescoin    _addressOfToken)   {
beneficiary=_beneficiary;
coldWallet=_coldWallet;
ethPrice=_ethPrice;
bonus=_bonus;
tokenReward=Lescoin(_addressOfToken);
}

function ()  payable {
uint256     amount = msg.value;
uint256     tokenAmount = (amount*ethPrice)/price/1000000000000;
if (tokenAmount<minSaleAmount)
throw;
amountRaised+=amount;
bool     __sent_result100 = tokenReward.transfer(msg.sender, (tokenAmount*(100+bonus))/100);
require(__sent_result100);
}

function WithdrawETH (uint256    _amount)   {
if (beneficiary!=msg.sender)
throw;
coldWallet.transfer(_amount);
}

function WithdrawTokens (uint256    _amount)   {
if (beneficiary!=msg.sender)
throw;
bool     __sent_result101 = tokenReward.transfer(coldWallet, _amount);
require(__sent_result101);
}

function TransferTokens (address    _to,uint256    _amount)   {
if (beneficiary!=msg.sender)
throw;
bool     __sent_result102 = tokenReward.transfer(_to, _amount);
require(__sent_result102);
}

function ChangeEthPrice (uint256    _ethPrice)   {
if (beneficiary!=msg.sender)
throw;
ethPrice=_ethPrice;
}

function ChangeBonus (uint256    _bonus)   {
if (beneficiary!=msg.sender)
throw;
bonus=_bonus;
}

}
