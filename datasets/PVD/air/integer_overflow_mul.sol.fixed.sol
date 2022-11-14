pragma solidity ^0.4.19;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function mul_uint(uint a, uint b) internal pure returns (uint) {
                                if (a == 0) {
                                        return 0;
                                }
                                uint c = a * b;
                                assert(c / a == b);
                                return c;
                        }
                                
                                
                                
                        }
                contract IntegerOverflowMul is sGuardPlus {
uint  public   count = 2;
function run (uint256    input) public  {
count=mul_uint(count, input);
}

}
