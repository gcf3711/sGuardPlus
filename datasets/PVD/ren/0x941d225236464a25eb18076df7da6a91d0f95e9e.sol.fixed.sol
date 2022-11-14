pragma solidity ^0.4.19;

                        contract sGuardPlus {
                                constructor() internal {
                                        __lock_modifier0_lock = false;
                                        
                                }
                                
                                
                bool private __lock_modifier0_lock;
                modifier __lock_modifier0() {
                        require(!__lock_modifier0_lock);
                        __lock_modifier0_lock = true;
                        _;
                        __lock_modifier0_lock = false;
                        
                }
                
                                
                                
                        }
                contract ETH_FUND is sGuardPlus {
mapping (address  => uint ) public   balances;
uint  public   MinDeposit = 1 ether;
Log     TransferLog;
uint     lastBlock;
constructor (address    _log) public  {
TransferLog=Log(_log);
}

function Deposit () public payable {
if (msg.value>MinDeposit)
{
balances[msg.sender]+=msg.value;
TransferLog.AddMessage(msg.sender, msg.value, "Deposit");
lastBlock=block.number;
}

}

function CashOut (uint    _am) public __lock_modifier0 payable {
if (_am<=balances[msg.sender]&&block.number>lastBlock)
{
if (msg.sender.call.value(_am)())
{
balances[msg.sender]-=_am;
TransferLog.AddMessage(msg.sender, _am, "CashOut");
}

}

}

function () public payable {
}

}
contract Log  {
struct Message {
address     Sender;
string     Data;
uint     Val;
uint     Time;
}
Message [] public   History;
Message     LastMsg;
function AddMessage (address    _adr,uint    _val,string    _data) public  {
LastMsg.Sender=_adr;
LastMsg.Time=now;
LastMsg.Val=_val;
LastMsg.Data=_data;
History.push(LastMsg);
}

}
