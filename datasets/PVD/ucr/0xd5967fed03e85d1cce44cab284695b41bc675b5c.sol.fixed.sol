pragma solidity ^0.4.0;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                
                                
                                
                                
                        }
                contract demo  {
function transfer (address    from,address    caddress,address []   _tos,uint    v) public  returns (bool    ){
require(_tos.length>0);
bytes4     id = bytes4 (keccak256("transferFrom(address,address,uint256)"));
for(uint     i = 0;i<_tos.length; i ++ ){
bool     __sent_result101 = caddress.call(id, from, _tos[i], v);
require(__sent_result101);
}

return true;
}

}
