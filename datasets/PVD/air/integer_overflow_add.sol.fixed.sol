pragma solidity ^0.4.19;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint(uint a, uint b) internal pure returns (uint) {
                                uint c = a + b;
                                assert(c >= a);
                                return c;
                        }
                                
                                
                                
                        }
                contract IntegerOverflowAdd is sGuardPlus {
uint  public   count = 1;
function run (uint256    input) public  {
count=add_uint(count, input);
}

}
