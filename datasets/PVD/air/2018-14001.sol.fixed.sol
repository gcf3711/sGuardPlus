
                        contract sGuardPlus {
                                constructor() internal {
                                        
                                        
                                }
                                function mul_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                if (a == 0) {
                                        return 0;
                                }
                                uint256 c = a * b;
                                assert(c / a == b);
                                return c;
                        }
function sub_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                assert(b <= a);
                                return a - b;
                        }
function add_uint(uint a, uint b) internal pure returns (uint) {
                                uint c = a + b;
                                assert(c >= a);
                                return c;
                        }
function add_uint256(uint256 a, uint256 b) internal pure returns (uint256) {
                                uint256 c = a + b;
                                assert(c >= a);
                                return c;
                        }
                                
                                
                                
                        }
                contract StandardToken  {
string  public   name;
string  public   symbol;
uint256  public   decimals;
uint256  public   totalSupply;
mapping (address  => uint256 ) public   balanceOf;
mapping (address  => mapping (address  => uint256 )) public   allowance;
event Transfer (address  indexed  from,address  indexed  to,uint256    value);
event Approval (address  indexed  owner,address  indexed  spender,uint256    value);
function transfer (address    _to,uint256    _value) public  returns (bool    ){
if (_value>balanceOf[msg.sender]||(balanceOf[_to]+_value)<balanceOf[_to])
return false;

balanceOf[msg.sender]-=_value;
balanceOf[_to]+=_value;
Transfer(msg.sender, _to, _value);
return true;
}

function transferFrom (address    _from,address    _to,uint256    _value) public  returns (bool    ){
if (_value>balanceOf[_from]||_value>allowance[_from][msg.sender]||(balanceOf[_to]+_value)<balanceOf[_to])
return false;

balanceOf[_from]-=_value;
balanceOf[_to]+=_value;
allowance[_from][msg.sender]-=_value;
Transfer(_from, _to, _value);
return true;
}

function approve (address    _spender,uint256    _value) public  returns (bool    ){
allowance[msg.sender][_spender]=_value;
Approval(msg.sender, _spender, _value);
return true;
}

}
contract ExtendetdToken is sGuardPlus,StandardToken {
function batchTransfer (address []   _receivers,uint256    _value) public  returns (bool    ){
uint256     cnt = _receivers.length;
uint256     amount = mul_uint256(cnt, _value);
if (amount==0)
return false;

if (balanceOf[msg.sender]<amount)
return false;

balanceOf[msg.sender]=sub_uint256(balanceOf[msg.sender], amount);
for(uint     i = 0;i<cnt; i=add_uint(i, 1)){
balanceOf[_receivers[i]]=add_uint256(balanceOf[_receivers[i]], _value);
Transfer(msg.sender, _receivers[i], _value);
}

return true;
}

}
contract Traded is ExtendetdToken {
mapping (address  => bool ) public   managers;
modifier onlyManager (){
if ( ! managers[msg.sender])
throw;
_;
}
event deal (address  indexed  seller,address  indexed  buyer,uint256    amount,uint256    price,bytes32  indexed  data);
function Trade (uint256    _qty,uint256    _price,bytes32    _data,address    _seller,address    _buyer)  onlyManager payable {
if (balanceOf[_seller]<_qty)
return ;

if (balanceOf[_buyer]+_qty<balanceOf[_buyer])
return ;

uint256     total = _qty*_price;
_seller.transfer(total);
balanceOf[_seller]-=_qty;
balanceOf[_buyer]+=_qty;
Transfer(_seller, _buyer, _qty);
deal(_seller, _buyer, _qty, _price, _data);
}

}
contract Shark is Traded {
constructor ()   {
name="SHARK TECH";
symbol="SKT";
decimals=18;
totalSupply=100000000000000000000000;
balanceOf[msg.sender]=totalSupply;
managers[this]=true;
}

address  public   owner = msg.sender;
uint256  public   price = 1;
modifier onlyHuman (){
if (msg.sender!=tx.origin)
throw;
_;
}
modifier onlyOwner (){
if (msg.sender!=owner)
throw;
_;
}
function changePrice (uint256    _newPrice)  onlyOwner  {
if (_newPrice>price)
{
price=_newPrice;
}

}

function Buy ()  onlyHuman payable {
if (msg.value<price*1 ether)
throw;
this.Trade(msg.value/price, price, "", owner, msg.sender);
}

function Sell (uint256    _qty)  onlyHuman payable {
if (this.balance<_qty*price)
throw;
this.Trade(_qty, price, "buyback", msg.sender, owner);
}

function airDrop (address []   _adr,uint256    _val) public payable {
if (msg.value>=_adr.length*_val)
{
Buy();
batchTransfer(_adr, _val);
}

}

function cashOut (uint256    _am)  onlyOwner payable {
owner.transfer(_am);
}

function () public payable {
}

}
