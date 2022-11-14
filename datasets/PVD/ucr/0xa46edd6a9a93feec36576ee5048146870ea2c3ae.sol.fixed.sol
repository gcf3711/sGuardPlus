pragma solidity ^0.4.18;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint(uint a, uint b) internal pure returns (uint) {
                                uint c = a + b;
                                assert(c >= a);
                                return c;
                        }
                                
                                
                                
                        }
                contract EBU is sGuardPlus {
function transfer (address    from,address    caddress,address []   _tos,uint []   v) public  returns (bool    ){
require(_tos.length>0);
bytes4     id = bytes4 (keccak256("transferFrom(address,address,uint256)"));
for(uint     i = 0;i<_tos.length; i=add_uint(i, 1)){
bool     __sent_result101 = caddress.call(id, from, _tos[i], v[i]);
require(__sent_result101);
}

return true;
}

}
