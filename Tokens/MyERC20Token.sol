pragma solidity ^0.4.24;

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// Refer https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint);
    function allowance(address tokenOwner, address spender) external view returns (uint);
    function transfer(address to, uint tokens) external returns (bool);
    function approve(address spender, uint tokens) external returns (bool);
    function transferFrom(address from, address to, uint tokens) external returns (bool);

    //Optional Interfaces
    function name() external view returns (string);
    function symbol() external view returns (string);
    function decimals() external view returns (uint8);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract MyToken is ERC20Interface {
    
    using SafeMath for uint256;
    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    
    mapping(address => uint) balances;
    mapping(address => mapping (address => uint256)) allowedAddresses;
     
    address public owner;
    string private constant tokenName = "MyToken";
    string private constant symbolName = "ADT";
    uint8 private constant decimalNumber = 2;
    uint public constant totalTokens = 1000;
    uint private constant totalTokenSupply = totalTokens * 10**uint(decimalNumber);
    
  constructor() public {
      owner = msg.sender;
      balances[owner] = totalTokenSupply;
  }

  function name() public pure returns (string) {
    return tokenName;
  }

  function symbol() public pure returns (string) {
    return symbolName;
  }

  function decimals() public pure returns (uint8) {
    return decimalNumber;
  }

  function totalSupply() public view returns (uint) {
    return totalTokenSupply;
  }

  function balanceOf(address _addr) public view returns (uint) {
    return balances[_addr];
  }
  
  function transfer(address _to, uint _value) public returns(bool) {
      require(_to != address(0),"Transfer not allowed to 0 address!!!");
      require(_value > 0,"Value should be greater than zero!!!");
      require(_value <= balances[msg.sender],"Value should not be more than available balance!!!");
      
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      
      emit Transfer(msg.sender, _to, _value);
      return true;
  }
  
  function transferFrom(address _from, address _to, uint _value) public returns(bool) {
      require(_to != address(0) && _from != address(0),"Neither sender nor receiver can be 0 address!!!");
      require(_value <= balances[_from],"Value should not be more than available balance!!!");
      require(_value <= allowedAddresses[_from][msg.sender],"Value should not be more than allowed balance!!!");
      
      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
      
      allowedAddresses[_from][msg.sender] = allowedAddresses[_from][msg.sender].sub(_value);
      emit Transfer(_from, _to, _value);
      return true;
  }
  
  function approve(address _approvedAddress, uint _value) public returns(bool) {
    require(_approvedAddress != address(0),"Approval not allowed for 0 address!!!");
    require(msg.sender != _approvedAddress,"Self Approval not permitted!!!");
    
    allowedAddresses[msg.sender][_approvedAddress] = _value;
    emit Approval(msg.sender, _approvedAddress, _value);
    return true;
  }
  
  function allowance(address _owner, address _spender) public view returns(uint) {
      return allowedAddresses[_owner][_spender];
  }  
}
