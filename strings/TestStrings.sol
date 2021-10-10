pragma solidity ^0.4.0; 

import "./StringLib.sol";

contract TestStrings {

    using Strings for string;
    string public str1;

    constructor (string message) public {
        str1 = message;
    }
    
    function testConcat1(string _base) public view returns (string) {
        return str1.concat1(_base);
    }
    
    function testConcat2(string _base) public view returns (string) {
         return str1.concat2(_base);
    }

    function testStrcmp(string _base) public view returns (string) {
        int8 status = str1.strcmp(_base);
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
    
    function testStringReverse(string _base) public pure returns (string) {
        return _base.strrev();
    }
    
    function resetString() public {
        str1 = "hello";
    }
}
