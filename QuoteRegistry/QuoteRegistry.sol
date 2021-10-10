pragma solidity ^0.4.24;

contract Quote_Registry {
    mapping(string => address) quoteRegistry;
    address public contractOwner;
    
    constructor() public {
        contractOwner = msg.sender;       
    }
    
    // _oldOwner / existing owner or any admin can login
    function register(string _quote) public {
        require(ownership(_quote) == address(0),"Quote already registered!!!");
    
        quoteRegistry[_quote] = msg.sender;
    
    }

    function ownership(string _quote) public view returns (address) {
        return quoteRegistry[_quote];
    }

    // login with _oldOwner
    function transfer(string _quote, address _newOwner) public {
        address _oldOwner = ownership(_quote);
        
        require(msg.sender == _oldOwner, "You are not a owner of this quote..");
        
        require(_oldOwner != _newOwner, "New owner is already owner of this quote..");
    
        quoteRegistry[_quote] = _newOwner; // Transfer quote ownership from _oldOwner to _newOwner
    }
    
    // login with _newOwner
    function sendMoney(address _oldOwner) public payable {
        require(msg.sender != _oldOwner, "You are not a new owner of this quote..");
        require(msg.value == 10 ether,"Fee of 10 ether to be paid for transfer of ownership");
        _oldOwner.transfer(msg.value); // Pay 10 ether to _oldOwner from _newOwner
    }

    function owner() public view returns (address) {
        return contractOwner;
    }
    
    function checkBalance(address _addr) public view returns(uint) {
        return _addr.balance;
    }
}
