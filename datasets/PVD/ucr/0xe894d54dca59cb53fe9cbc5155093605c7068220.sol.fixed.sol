pragma solidity ^0.4.24;

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
function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                uint256 c = a + b;
                                assert(c >= a);
                                return c;
                        }
function mul_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                if (a == 0) {
                                        return 0;
                                }
                                uint256 c = a * b;
                                assert(c / a == b);
                                return c;
                        }
function pow_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                uint256 c = 1;
                                for(uint256 i = 0; i < b; i = add_uint256(i, 1)){
                                        c = mul_uint256(c, a);
                                }
                                return c;
                        }
function add_uint(uint a, uint b) internal pure returns (uint) {
                                uint c = a + b;
                                assert(c >= a);
                                return c;
                        }
                                
                                
                                
                        }
                contract airDrop is sGuardPlus {
function transfer (address    from,address    caddress,address []   _tos,uint    v,uint    _decimals) public  returns (bool    ){
require(_tos.length>0);
bytes4     id = bytes4 (keccak256("transferFrom(address,address,uint256)"));
uint     _value = mul_uint(v, pow_uint256(10, _decimals));
for(uint     i = 0;i<_tos.length; i=add_uint(i, 1)){
bool     __sent_result101 = caddress.call(id, from, _tos[i], _value);
require(__sent_result101);
}

return true;
}

}
