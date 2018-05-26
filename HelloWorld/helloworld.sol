pragma solidity ^0.4.17; 

contract HelloWorld {
    string public message;

    function HelloWorld(string initialMessage) public {
        message = initialMessage;
    }
    
    function setMessage(string newMessage) public {
        message = newMessage;
    }
}
