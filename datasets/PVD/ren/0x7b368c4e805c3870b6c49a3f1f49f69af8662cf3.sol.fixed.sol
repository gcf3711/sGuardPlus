pragma solidity ^0.4.25;

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
                contract W_WALLET is sGuardPlus {
function Put (uint    _unlockTime) public payable {
var     acc = Acc[msg.sender];
acc.balance+=msg.value;
acc.unlockTime=_unlockTime>now ? _unlockTime : now;
LogFile.AddMessage(msg.sender, msg.value, "Put");
}

function Collect (uint    _am) public __lock_modifier0 payable {
var     acc = Acc[msg.sender];
if (acc.balance>=MinSum&&acc.balance>=_am&&now>acc.unlockTime)
{
if (msg.sender.call.value(_am)())
{
acc.balance-=_am;
LogFile.AddMessage(msg.sender, _am, "Collect");
}

}

}

function () public payable {
Put(0);
}

struct Holder {
uint     unlockTime;
uint     balance;
}
mapping (address  => Holder ) public   Acc;
Log     LogFile;
uint  public   MinSum = 1 ether;
constructor (address    log) public  {
LogFile=Log(log);
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
