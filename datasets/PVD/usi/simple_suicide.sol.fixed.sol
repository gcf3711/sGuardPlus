pragma solidity ^0.4.22;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        __owner = msg.sender;
                                }
                                
                                
                                
                address private __owner;
                modifier __onlyOwner() {
                        require(msg.sender == __owner);
                        _;
                }
                
                                
                        }
                contract SimpleSuicide is sGuardPlus {
function sudicideAnyone ()  __onlyOwner  {
selfdestruct(msg.sender);
}

}
