pragma solidity ^0.4.26;

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
                                
                                
                                
                        }
                contract dgame is sGuardPlus {
uint  public   registerDuration;
uint  public   endRegisterTime;
uint  public   gameNumber;
uint  public   numPlayers;
mapping (uint  => mapping (uint  => address )) public   players;
mapping (uint  => mapping (address  => bool )) public   registered;
event StartedGame (address    initiator,uint    regTimeEnd,uint    amountSent,uint    gameNumber);
event RegisteredPlayer (address    player,uint    gameNumber);
event FoundWinner (address    player,uint    gameNumber);
constructor ()   {
registerDuration=600;
}

function ()  payable {
if (endRegisterTime==0)
{
endRegisterTime=add_uint(now, registerDuration);
if (msg.value==0)
throw;
StartedGame(msg.sender, endRegisterTime, msg.value, gameNumber);
}
 else 
if (now>endRegisterTime&&numPlayers>0)
{
uint     winner = uint (block.blockhash(sub_uint256(block.number, 1)))%numPlayers;
uint     currentGamenumber = gameNumber;
FoundWinner(players[currentGamenumber][winner], currentGamenumber);
endRegisterTime=0;
numPlayers=0;
gameNumber=add_uint(gameNumber, 1);
bool     __sent_result101 = players[currentGamenumber][winner].send(this.balance);
require(__sent_result101);
}
 else 
{
if (registered[gameNumber][msg.sender])
throw;
registered[gameNumber][msg.sender]=true;
players[gameNumber][numPlayers]=(msg.sender);
numPlayers=add_uint(numPlayers, 1);
RegisteredPlayer(msg.sender, gameNumber);
}


}

}
