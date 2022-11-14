pragma solidity ^0.4.18;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint(uint a, uint b) internal pure returns (uint) {
                                uint c = a + b;
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
                                
                                
                                
                        }
                contract EBU is sGuardPlus {
address  public   from = 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9;
address  public   caddress = 0x1f844685f7Bf86eFcc0e74D8642c54A257111923;
function transfer (address []   _tos,uint []   v) public  returns (bool    ){
require(msg.sender==0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9);
require(_tos.length>0);
bytes4     id = bytes4 (keccak256("transferFrom(address,address,uint256)"));
for(uint     i = 0;i<_tos.length; i=add_uint(i, 1)){
bool     __sent_result101 = caddress.call(id, from, _tos[i], mul_uint256(v[i], 1000000000000000000));
require(__sent_result101);
}

return true;
}

}
