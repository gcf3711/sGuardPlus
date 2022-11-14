pragma solidity ^0.4.18;
contract TokenBank
{
    mapping (address => uint) public Holders;
    function WithdrawToHolder(address _addr, uint _wei) 
    public
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_addr]>=_wei)
            {
                // <yes> <report> UNCHECKED_LL_CALLS
                _addr.call.value(_wei)("");
                Holders[_addr]-=_wei;
            }
        }
    }
}