pragma solidity 0.4.26;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function add_uint(uint a, uint b) internal pure returns (uint) {
                                uint c = a + b;
                                assert(c >= a);
                                return c;
                        }
                                
                                
                                
                        }
                contract Overflow_Add is sGuardPlus {
uint  public   balance = 1;
function add (uint256    deposit) public  {
balance=add_uint(balance, deposit);
}

}
