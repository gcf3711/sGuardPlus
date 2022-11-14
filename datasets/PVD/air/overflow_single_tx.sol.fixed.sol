pragma solidity ^0.4.23;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint(uint a, uint b) internal pure returns (uint) {
                                uint c = a + b;
                                assert(c >= a);
                                return c;
                        }
function mul_uint(uint a, uint b) internal pure returns (uint) {
                                if (a == 0) {
                                        return 0;
                                }
                                uint c = a * b;
                                assert(c / a == b);
                                return c;
                        }
function sub_uint(uint a, uint b) internal pure returns (uint) {
                                assert(b <= a);
                                return a - b;
                        }
                                
                                
                                
                        }
                contract IntegerOverflowSingleTransaction is sGuardPlus {
uint  public   count = 1;
function overflowaddtostate (uint256    input) public  {
count=add_uint(count, input);
}

function overflowmultostate (uint256    input) public  {
count=mul_uint(count, input);
}

function underflowtostate (uint256    input) public  {
count=sub_uint(count, input);
}

function overflowlocalonly (uint256    input) public  {
uint     res = count+input;
}

function overflowmulocalonly (uint256    input) public  {
uint     res = mul_uint(count, input);
}

function underflowlocalonly (uint256    input) public  {
uint     res = count-input;
}

}
