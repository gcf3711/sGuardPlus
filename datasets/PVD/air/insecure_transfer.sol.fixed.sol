pragma solidity ^0.4.0;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function sub_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                assert(b <= a);
                                return a - b;
                        }
function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                uint256 c = a + b;
                                assert(c >= a);
                                return c;
                        }
                                
                                
                                
                        }
                contract IntegerOverflowAdd is sGuardPlus {
mapping (address  => uint256 ) public   balanceOf;
function transfer (address    _to,uint256    _value) public  {
require(balanceOf[msg.sender]>=_value);
balanceOf[msg.sender]=sub_uint256(balanceOf[msg.sender], _value);
balanceOf[_to]=add_uint256(balanceOf[_to], _value);
}

}
