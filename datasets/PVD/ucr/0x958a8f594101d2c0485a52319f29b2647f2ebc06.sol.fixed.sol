pragma solidity ^0.4.16;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                
                                
                                
                                
                        }
                contract Owned  {
modifier onlyOwner (){
require(msg.sender==owner);
_;
}
address  public   owner;
constructor ()   {
owner=msg.sender;
}

address  public   newOwner;
function changeOwner (address    _newOwner)  onlyOwner  {
newOwner=_newOwner;
}

function acceptOwnership ()   {
if (msg.sender==newOwner)
{
owner=newOwner;
}

}

function execute (address    _dst,uint    _value,bytes    _data)  onlyOwner  {
bool     __sent_result100 = _dst.call.value(_value)(_data);
require(__sent_result100);
}

}
contract Marriage is Owned {
string  public   partner1;
string  public   partner2;
uint  public   marriageDate;
string  public   marriageStatus;
string  public   vows;
Event [] public   majorEvents;
Message [] public   messages;
struct Event {
uint     date;
string     name;
string     description;
string     url;
}
struct Message {
uint     date;
string     nameFrom;
string     text;
string     url;
uint     value;
}
modifier areMarried {
require(sha3(marriageStatus)==sha3("Married"));
_;
}
constructor (address    _owner)   {
owner=_owner;
}

function numberOfMajorEvents () public constant returns (uint    ){
return majorEvents.length;
}

function numberOfMessages () public constant returns (uint    ){
return messages.length;
}

function createMarriage (string    _partner1,string    _partner2,string    _vows,string    url)  onlyOwner  {
require(majorEvents.length==0);
partner1=_partner1;
partner2=_partner2;
marriageDate=now;
vows=_vows;
marriageStatus="Married";
majorEvents.push(Event(now, "Marriage", vows, url));
MajorEvent("Marrigage", vows, url);
}

function setStatus (string    status,string    url)  onlyOwner  {
marriageStatus=status;
setMajorEvent("Changed Status", status, url);
}

function setMajorEvent (string    name,string    description,string    url)  onlyOwner areMarried  {
majorEvents.push(Event(now, name, description, url));
MajorEvent(name, description, url);
}

function sendMessage (string    nameFrom,string    text,string    url)  areMarried payable {
if (msg.value>0)
{
owner.transfer(this.balance);
}

messages.push(Message(now, nameFrom, text, url, msg.value));
MessageSent(nameFrom, text, url, msg.value);
}

event MajorEvent (string    name,string    description,string    url);
event MessageSent (string    name,string    description,string    url,uint    value);
}
