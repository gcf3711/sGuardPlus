pragma solidity ^0.4.18;

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
                contract Reentrance is sGuardPlus {
mapping (address  => uint ) public   balances;
function donate (address    _to) public payable {
balances[_to]+=msg.value;
}

function balanceOf (address    _who) public view returns (uint    balance){
return balances[_who];
}

function withdraw (uint    _amount) public __lock_modifier0  {
if (balances[msg.sender]>=_amount)
{
if (msg.sender.call.value(_amount)())
{
_amount;
}

balances[msg.sender]-=_amount;
}

}

function () public payable {
}

}
