pragma solidity ^0.4.0;

import "./StringLib.sol";

contract TestStrings {
    
    using Strings for string;
    string public str1;
    
    constructor (string message) public {
        str1 = message;
    }
    function testConcat(string _base) public {
        str1 = str1.concat(_base);
    }
    
    function testStrcmp(string _base) public view returns (string) {
        uint status = str1.strcmp(_base);
        if(status == 0)
            return "strings are same";
        else
            return "strings are different";
    }
    
    function testCompareStrings(string str2) public view returns (string) {
        bool status = str1.compareStrings(str2);
        if(status)
            return "strings are same";
        else
            return "strings are different";
    }
}
