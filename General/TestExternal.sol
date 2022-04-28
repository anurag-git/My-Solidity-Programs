// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.*; 
import "hardhat/console.sol";

contract TestExt {

    function funA() external view {
        console.log("This is funA()...");
    }

    function funB() public view {
        this.funA(); // calling external funA() from within smart contract public function
        console.log("This is funB()...");
    }

    function funC() public view {
        this.funB(); //calling another public function which calls external function
        console.log("This is funC()...");
    }
}
