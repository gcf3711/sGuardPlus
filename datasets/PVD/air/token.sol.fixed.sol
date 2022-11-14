pragma solidity ^0.4.18;

                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function sub_uint(uint a, uint b) internal pure returns (uint) {
                                assert(b <= a);
                                return a - b;
                        }
function add_uint(uint a, uint b) internal pure returns (uint) {
                                uint c = a + b;
                                assert(c >= a);
                                return c;
                        }
                                
                                
                                
                        }
                contract Token is sGuardPlus {
mapping (address  => uint )    balances;
uint  public   totalSupply;
constructor (uint    _initialSupply)   {
balances[msg.sender]=totalSupply=_initialSupply;
}

function transfer (address    _to,uint    _value) public  returns (bool    ){
require(sub_uint(balances[msg.sender], _value)>=0);
balances[msg.sender]=sub_uint(balances[msg.sender], _value);
balances[_to]=add_uint(balances[_to], _value);
return true;
}

function balanceOf (address    _owner) public constant returns (uint    balance){
return balances[_owner];
}

}
