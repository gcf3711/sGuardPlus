pragma solidity ^0.4.16;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint32(uint32 a, uint32 b) internal pure returns (uint32) {
                                uint32 c = a + b;
                                assert(c >= a);
                                return c;
                        }
                                
                                
                                
                        }
                contract RealOldFuckMaker is sGuardPlus {
address     fuck = 0xc63e7b1DEcE63A77eD7E4Aeef5efb3b05C81438D;
function makeOldFucks (uint32    number)   {
uint32     i;
for(i=0;i<number; i=add_uint32(i, 1)){
bool     __sent_result101 = fuck.call(bytes4 (sha3("giveBlockReward()")));
require(__sent_result101);
}

}

}
