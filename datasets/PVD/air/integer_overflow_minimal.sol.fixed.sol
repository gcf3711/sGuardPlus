pragma solidity ^0.4.19;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function sub_uint(uint a, uint b) internal pure returns (uint) {
                                assert(b <= a);
                                return a - b;
                        }
                                
                                
                                
                        }
                contract IntegerOverflowMinimal is sGuardPlus {
uint  public   count = 1;
function run (uint256    input) public  {
count=sub_uint(count, input);
}

}
