pragma solidity ^0.4.11;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function sub_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                assert(b <= a);
                                return a - b;
                        }
                                
                                
                                
                        }
                contract IntegerOverflowMappingSym1 is sGuardPlus {
mapping (uint256  => uint256 )    map;
function init (uint256    k,uint256    v) public  {
map[k]=sub_uint256(map[k], v);
}

}
