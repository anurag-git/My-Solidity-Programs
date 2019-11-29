pragma solidity ^0.4.25;
contract D {
  uint public n;
  address public sender;

  function callSetN(address _e, uint _n) public {
    _e.call(bytes4(keccak256("setN(uint256)")), _n); // E's storage is set, D is not modified, msg.sender is D
  }

  function callcodeSetN(address _e, uint _n) public {
    _e.callcode(bytes4(keccak256("setN(uint256)")), _n); // D's storage is set, E is not modified, msg.sender is D 
  }

  function delegatecallSetN(address _e, uint _n) public {
    _e.delegatecall(bytes4(keccak256("setN(uint256)")), _n); // D's storage is set, E is not modified, msg.sender is C
  }
}

contract E {
  uint public n;
  address public sender;

  function setN(uint _n) public {
    n = _n;
    sender = msg.sender;
  }
}

contract C {
    function foo(D _d, E _e, uint _n) public {
        _d.delegatecallSetN(_e, _n);
    }
    
    function foo1(D _d, E _e, uint _n) public {
        _d.callcodeSetN(_e, _n);
    }
    
    function foo2(D _d, E _e, uint _n) public {
        _d.callSetN(_e, _n);
    }
}
