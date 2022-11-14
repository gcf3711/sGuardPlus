pragma solidity ^0.4.21;

                        contract sGuardPlus {
                                constructor() internal {
                                        __lock_modifier0_lock = false;
__lock_modifier1_lock = false;
                                        
                                }
                                
                                
                bool private __lock_modifier0_lock;
                modifier __lock_modifier0() {
                        require(!__lock_modifier0_lock);
                        __lock_modifier0_lock = true;
                        _;
                        __lock_modifier0_lock = false;
                        
                }
                

                bool private __lock_modifier1_lock;
                modifier __lock_modifier1() {
                        require(!__lock_modifier1_lock);
                        __lock_modifier1_lock = true;
                        _;
                        __lock_modifier1_lock = false;
                        
                }
                
                                
                                
                        }
                contract PoCGame is sGuardPlus {
modifier onlyOwner (){
require(msg.sender==owner);
_;
}
modifier isOpenToPublic (){
require(openToPublic);
_;
}
modifier onlyRealPeople (){
require(msg.sender==tx.origin);
_;
}
modifier onlyPlayers (){
require(wagers[msg.sender]>0);
_;
}
event Wager (uint256    amount,address    depositer);
event Win (uint256    amount,address    paidTo);
event Lose (uint256    amount,address    loser);
event Donate (uint256    amount,address    paidTo,address    donator);
event DifficultyChanged (uint256    currentDifficulty);
event BetLimitChanged (uint256    currentBetLimit);
address  private   whale;
uint256     betLimit;
uint     difficulty;
uint  private   randomSeed;
address     owner;
mapping (address  => uint256 )    timestamps;
mapping (address  => uint256 )    wagers;
bool     openToPublic;
uint256     totalDonated;
constructor (address    whaleAddress,uint256    wagerLimit) public onlyRealPeople()  {
openToPublic=false;
owner=msg.sender;
whale=whaleAddress;
totalDonated=0;
betLimit=wagerLimit;
}

function OpenToThePublic () public onlyOwner()  {
openToPublic=true;
}

function AdjustBetAmounts (uint256    amount) public onlyOwner()  {
betLimit=amount;
emit BetLimitChanged(betLimit);
}

function AdjustDifficulty (uint256    amount) public onlyOwner()  {
difficulty=amount;
emit DifficultyChanged(difficulty);
}

function () public payable {
}

function wager () public isOpenToPublic() onlyRealPeople() payable {
require(msg.value==betLimit);
timestamps[msg.sender]=block.number;
wagers[msg.sender]=msg.value;
emit Wager(msg.value, msg.sender);
}

function play () public isOpenToPublic() onlyRealPeople() onlyPlayers()  {
uint256     blockNumber = timestamps[msg.sender];
if (blockNumber<block.number)
{
timestamps[msg.sender]=0;
wagers[msg.sender]=0;
uint256     winningNumber = uint256 (keccak256(abi.encodePacked(blockhash(blockNumber), msg.sender)))%difficulty+1;
if (winningNumber==difficulty/2)
{
payout(msg.sender);
}
 else 
{
loseWager(betLimit/2);
}

}
 else 
{
revert();
}

}

function donate () public isOpenToPublic() __lock_modifier0 payable {
donateToWhale(msg.value);
}

function payout (address    winner) internal  {
uint256     ethToTransfer = address (this).balance/2;
winner.transfer(ethToTransfer);
emit Win(ethToTransfer, winner);
}

function donateToWhale (uint256    amount) internal __lock_modifier1  {
bool     __sent_result100 = whale.call.value(amount)(bytes4 (keccak256("donate()")));
require(__sent_result100);
totalDonated+=amount;
emit Donate(amount, whale, msg.sender);
}

function loseWager (uint256    amount) internal __lock_modifier0  {
bool     __sent_result101 = whale.call.value(amount)(bytes4 (keccak256("donate()")));
require(__sent_result101);
totalDonated+=amount;
emit Lose(amount, msg.sender);
}

function ethBalance () public view returns (uint256    ){
return address (this).balance;
}

function currentDifficulty () public view returns (uint256    ){
return difficulty;
}

function currentBetLimit () public view returns (uint256    ){
return betLimit;
}

function hasPlayerWagered (address    player) public view returns (bool    ){
if (wagers[player]>0)
{
return true;
}
 else 
{
return false;
}

}

function winnersPot () public view returns (uint256    ){
return address (this).balance/2;
}

function transferAnyERC20Token (address    tokenAddress,address    tokenOwner,uint    tokens) public onlyOwner()  returns (bool    success){
return ERC20Interface(tokenAddress).transfer(tokenOwner, tokens);
}

}
contract ERC20Interface  {
function transfer (address    to,uint256    tokens) public  returns (bool    success);
}
