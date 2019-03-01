pragma solidity ^0.4.24;

import "github.com/Arachnid/solidity-stringutils/src/strings.sol";

contract SayHelloToMsgDotSender {
    using strings for *;
    string message;

    function addressToString(address _addr) public pure returns(string) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";
    
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
  
    function setMessage(string memory _message) public {
        string memory space = " ";
        message = _message.toSlice().concat(space.toSlice());
    }
    
    function getMessage() public view returns (string memory) {
        return message;
    }
    
    function getMessage1() public view returns (string memory) {
        string memory addr = addressToString(msg.sender);
        return message.toSlice().concat(addr.toSlice());
    }
}
