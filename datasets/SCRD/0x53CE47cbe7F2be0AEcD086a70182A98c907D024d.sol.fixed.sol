pragma solidity ^0.4.13;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
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
function pow_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                uint256 c = 1;
                                for(uint256 i = 0; i < b; i = add_uint256(i, 1)){
                                        c = mul_uint256(c, a);
                                }
                                return c;
                        }
function div_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                uint256 c = a / b;
                                return c;
                        }
                                
                                
                                
                        }
                contract Token  {
uint256  public   totalSupply;
function balanceOf (address    _owner)  constant returns (uint256    balance);
function transfer (address    _to,uint256    _value)   returns (bool    success);
function transferFrom (address    _from,address    _to,uint256    _value)   returns (bool    success);
function approve (address    _spender,uint256    _value)   returns (bool    success);
function allowance (address    _owner,address    _spender)  constant returns (uint256    remaining);
event Transfer (address  indexed  _from,address  indexed  _to,uint256    _value);
event Approval (address  indexed  _owner,address  indexed  _spender,uint256    _value);
}
contract StandardToken is sGuardPlus,Token {
function transfer (address    _to,uint256    _value)   returns (bool    success){
if (balances[msg.sender]>=_value&&_value>0)
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

function transferFrom (address    _from,address    _to,uint256    _value)   returns (bool    success){
if (balances[_from]>=_value&&allowed[_from][msg.sender]>=_value&&_value>0)
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

function balanceOf (address    _owner)  constant returns (uint256    balance){
return balances[_owner];
}

function approve (address    _spender,uint256    _value)   returns (bool    success){
allowed[msg.sender][_spender]=_value;
Approval(msg.sender, _spender, _value);
return true;
}

function allowance (address    _owner,address    _spender)  constant returns (uint256    remaining){
return allowed[_owner][_spender];
}

mapping (address  => uint256 )    balances;
mapping (address  => mapping (address  => uint256 ))    allowed;
}
contract EasyMineToken is sGuardPlus,StandardToken {
string  public constant  name = "easyMINE Token";
string  public constant  symbol = "EMT";
uint8  public constant  decimals = 18;
constructor (address    _icoAddress,address    _preIcoAddress,address    _easyMineWalletAddress,address    _bountyWalletAddress)   {
require(_icoAddress!=0x0);
require(_preIcoAddress!=0x0);
require(_easyMineWalletAddress!=0x0);
require(_bountyWalletAddress!=0x0);
totalSupply=mul_uint256(33000000, pow_uint256(10, 18));
uint256     icoTokens = mul_uint256(27000000, pow_uint256(10, 18));
uint256     preIcoTokens = mul_uint256(2000000, pow_uint256(10, 18));
uint256     easyMineTokens = mul_uint256(3000000, pow_uint256(10, 18));
uint256     bountyTokens = mul_uint256(1000000, pow_uint256(10, 18));
assert(add_uint256(add_uint256(add_uint256(icoTokens, preIcoTokens), easyMineTokens), bountyTokens)==totalSupply);
balances[_icoAddress]=icoTokens;
Transfer(0, _icoAddress, icoTokens);
balances[_preIcoAddress]=preIcoTokens;
Transfer(0, _preIcoAddress, preIcoTokens);
balances[_easyMineWalletAddress]=easyMineTokens;
Transfer(0, _easyMineWalletAddress, easyMineTokens);
balances[_bountyWalletAddress]=bountyTokens;
Transfer(0, _bountyWalletAddress, bountyTokens);
}

function burn (uint256    _value)   returns (bool    success){
if (balances[msg.sender]>=_value&&_value>0)
{
balances[msg.sender]-=_value;
totalSupply-=_value;
Transfer(msg.sender, 0x0, _value);
return true;
}
 else 
{
return false;
}

}

}
contract EasyMineTokenWallet is sGuardPlus {
uint256  public constant  VESTING_PERIOD = 180 days;
uint256  public constant  DAILY_FUNDS_RELEASE = 15000*10**18;
address  public   owner;
address  public   withdrawalAddress;
Token  public   easyMineToken;
uint256  public   startTime;
uint256  public   totalWithdrawn;
modifier isOwner (){
require(msg.sender==owner);
_;
}
constructor ()   {
owner=msg.sender;
}

function setup (address    _easyMineToken,address    _withdrawalAddress) public isOwner  {
require(_easyMineToken!=0x0);
require(_withdrawalAddress!=0x0);
easyMineToken=Token(_easyMineToken);
withdrawalAddress=_withdrawalAddress;
startTime=now;
}

function withdraw (uint256    requestedAmount) public isOwner  returns (uint256    amount){
uint256     limit = maxPossibleWithdrawal();
uint256     withdrawalAmount = requestedAmount;
if (requestedAmount>limit)
{
withdrawalAmount=limit;
}

if (withdrawalAmount>0)
{
if ( ! easyMineToken.transfer(withdrawalAddress, withdrawalAmount))
{
revert();
}

totalWithdrawn+=withdrawalAmount;
}

return withdrawalAmount;
}

function maxPossibleWithdrawal () public constant returns (uint256    ){
if (now<add_uint256(startTime, VESTING_PERIOD))
{
return 0;
}
 else 
{
uint256     daysPassed = div_uint256((sub_uint256(now, (add_uint256(startTime, VESTING_PERIOD)))), 86400);
uint256     res = sub_uint256(mul_uint256(DAILY_FUNDS_RELEASE, daysPassed), totalWithdrawn);
if (res<0)
{
return 0;
}
 else 
{
return res;
}

}

}

}
contract EasyMineIco  {
event TokensSold (address  indexed  buyer,uint256    amount);
event TokensReserved (uint256    amount);
event IcoFinished (uint256    burned);
struct PriceThreshold {
uint256     tokenCount;
uint256     price;
uint256     tokensSold;
}
uint256  public   maxDuration;
uint256  public   minStartDelay;
address  public   owner;
address  public   sys;
address  public   reservationAddress;
address  public   wallet;
EasyMineToken  public   easyMineToken;
uint256  public   startBlock;
uint256  public   endBlock;
PriceThreshold [3] public   priceThresholds;
Stages  public   stage;
enum Stages {
Deployed, 
SetUp, 
StartScheduled, 
Started, 
Ended
}
modifier atStage (Stages    _stage){
require(stage==_stage);
_;
}
modifier isOwner (){
require(msg.sender==owner);
_;
}
modifier isSys (){
require(msg.sender==sys);
_;
}
modifier isValidPayload (){
require(msg.data.length==0||msg.data.length==4);
_;
}
modifier timedTransitions (){
if (stage==Stages.StartScheduled&&block.number>=startBlock)
{
stage=Stages.Started;
}

if (stage==Stages.Started&&block.number>=endBlock)
{
finalize();
}

_;
}
constructor (address    _wallet) public  {
require(_wallet!=0x0);
owner=msg.sender;
wallet=_wallet;
stage=Stages.Deployed;
}

function () public timedTransitions payable {
if (stage==Stages.Started)
{
buyTokens();
}
 else 
{
revert();
}

}

function setup (address    _easyMineToken,address    _sys,address    _reservationAddress,uint256    _minStartDelay,uint256    _maxDuration) public isOwner atStage(Stages.Deployed)  {
require(_easyMineToken!=0x0);
require(_sys!=0x0);
require(_reservationAddress!=0x0);
require(_minStartDelay>0);
require(_maxDuration>0);
priceThresholds[0]=PriceThreshold(2000000*10**18, 0.00070*10**18, 0);
priceThresholds[1]=PriceThreshold(2000000*10**18, 0.00075*10**18, 0);
priceThresholds[2]=PriceThreshold(23000000*10**18, 0.00080*10**18, 0);
easyMineToken=EasyMineToken(_easyMineToken);
sys=_sys;
reservationAddress=_reservationAddress;
minStartDelay=_minStartDelay;
maxDuration=_maxDuration;
assert(easyMineToken.balanceOf(this)==maxTokensSold());
stage=Stages.SetUp;
}

function maxTokensSold () public constant returns (uint256    ){
uint256     total = 0;
for(uint8     i = 0;i<priceThresholds.length; i ++ ){
total+=priceThresholds[i].tokenCount;
}

return total;
}

function totalTokensSold () public constant returns (uint256    ){
uint256     total = 0;
for(uint8     i = 0;i<priceThresholds.length; i ++ ){
total+=priceThresholds[i].tokensSold;
}

return total;
}

function scheduleStart (uint256    _startBlock) public isOwner atStage(Stages.SetUp)  {
require(_startBlock>block.number+minStartDelay);
startBlock=_startBlock;
endBlock=startBlock+maxDuration;
stage=Stages.StartScheduled;
}

function updateStage () public timedTransitions  returns (Stages    ){
return stage;
}

function buyTokens () public isValidPayload timedTransitions atStage(Stages.Started) payable {
require(msg.value>0);
uint256     amountRemaining = msg.value;
uint256     tokensToReceive = 0;
for(uint8     i = 0;i<priceThresholds.length; i ++ ){
uint256     tokensAvailable = priceThresholds[i].tokenCount-priceThresholds[i].tokensSold;
uint256     maxTokensByAmount = amountRemaining*10**18/priceThresholds[i].price;
uint256     tokens;
if (maxTokensByAmount>tokensAvailable)
{
tokens=tokensAvailable;
amountRemaining-=(priceThresholds[i].price*tokens)/10**18;
}
 else 
{
tokens=maxTokensByAmount;
amountRemaining=0;
}

priceThresholds[i].tokensSold+=tokens;
tokensToReceive+=tokens;
}

assert(tokensToReceive>0);
if (amountRemaining!=0)
{
assert(msg.sender.send(amountRemaining));
}

assert(wallet.send(msg.value-amountRemaining));
assert(easyMineToken.transfer(msg.sender, tokensToReceive));
if (totalTokensSold()==maxTokensSold())
{
finalize();
}

TokensSold(msg.sender, tokensToReceive);
}

function reserveTokens (uint256    tokenCount) public isSys timedTransitions atStage(Stages.Started)  {
require(tokenCount>0);
uint256     tokensRemaining = tokenCount;
for(uint8     i = 0;i<priceThresholds.length; i ++ ){
uint256     tokensAvailable = priceThresholds[i].tokenCount-priceThresholds[i].tokensSold;
uint256     tokens;
if (tokensRemaining>tokensAvailable)
{
tokens=tokensAvailable;
}
 else 
{
tokens=tokensRemaining;
}

priceThresholds[i].tokensSold+=tokens;
tokensRemaining-=tokens;
}

uint256     tokensReserved = tokenCount-tokensRemaining;
assert(easyMineToken.transfer(reservationAddress, tokensReserved));
if (totalTokensSold()==maxTokensSold())
{
finalize();
}

TokensReserved(tokensReserved);
}

function cleanup () public isOwner timedTransitions atStage(Stages.Ended)  {
assert(owner.send(this.balance));
}

function finalize () private  {
stage=Stages.Ended;
uint256     balance = easyMineToken.balanceOf(this);
bool     __sent_result100 = easyMineToken.burn(balance);
require(__sent_result100);
IcoFinished(balance);
}

}
