pragma solidity ^0.4.23;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function sub_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                assert(b <= a);
                                return a - b;
                        }
                                
                                
                                
                        }
                contract IntegerOverflowMultiTxOneFuncFeasible is sGuardPlus {
uint256  private   initialized = 0;
uint256  public   count = 1;
function run (uint256    input) public  {
if (initialized==0)
{
initialized=1;
return ;
}

count=sub_uint256(count, input);
}

}
