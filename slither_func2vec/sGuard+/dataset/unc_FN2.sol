//mythril  0x75aa81161e07483f6ca199fef46c13eb13d190be.fallback
pragma solidity ^0.4.21;
contract test{
    function post(uint128 val_, uint32 zzz_, address med_) public
        {
            bool ret = med_.call(bytes4(keccak256("poke()")));
            ret;
        }
}