// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.*; 
import "hardhat/console.sol";

contract StorageTest {

    string public string1="foo1"; // string1 is storage

    // Gas used - 27767
    function func1(string memory param1) public view { // param1 is memory, calldata is preferred bcoz it can't be modified, and saves gas
        string memory string2 = "foo2";  // string2 is memory in this instance
        
        console.log("param1=",param1);
        console.log("string2=",string2);
    }

    // Gas used - 27463
    function func2(string calldata param2) public view { // param2 is calldata
        string memory string3 = "foo3";  // string2 is memory in this instance
        
        console.log("param2=",param2);
        console.log("string3=",string3);
    }
}
