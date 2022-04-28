// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.*; 
import "hardhat/console.sol";

contract TestMapping {

    mapping (uint => uint) map1; // Correct, Default storage location is used
    mapping (uint => uint) storage map2; // Error, no need to specify "storage" as its default 
    mapping (uint => uint) memory map3; // Error, Default is storage, no need to specify it explicitly. 
                                        // memory is definitely and error

    function func1() public view {
        mapping (uint => uint) storage map3; // Error, as mapping is stored by defualt in storage 
                                             // and considered global, it is not allowed inside function

    }
}
