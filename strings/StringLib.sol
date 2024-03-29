pragma solidity ^0.4.0; 

library Strings {
    function concat1(string _base, string _value) internal pure returns (string) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);
        
        string memory _tmpValue = new string(_baseBytes.length + _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);
        
        uint i;
        uint j;
        
        for(i=0;i<_baseBytes.length;i++) {
            _newValue[j++] = _baseBytes[i];
        }
    
        
        for(i=0;i<_valueBytes.length;i++) {
            _newValue[j++] = _valueBytes[i];
        }
        
        return string(_newValue);
    }
    
    function concat2(string _base, string _value) internal pure returns (string) {
        return string(abi.encodePacked(_base, " ", _value));
    }
    
    function strcmp(string _firstStr, string _secondStr) internal pure returns (int8) {
        bytes memory _firstBytes = bytes(_firstStr);
        bytes memory _secondBytes = bytes(_secondStr);
        
        int8 flag = 0;
        
        if(_firstBytes.length != _secondBytes.length)
            flag = 1;
        
        for(uint i=0;i<_firstBytes.length;i++) {
            if(_firstBytes[i] != _secondBytes[i])
                flag = 1;
        }
    
        return flag;
    }
        
    function compareStrings (string a, string b) internal pure returns (bool) {
       return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
    
    function strrev(string _strToReverse) internal pure returns (string) {
        bytes memory _strBytes = bytes(_strToReverse);
        assert(_strBytes.length > 0);
        
        string memory _tmpStr = new string(_strBytes.length);
        bytes memory _strToReturn = bytes(_tmpStr);
        uint j=0;
        
        for(uint i=_strBytes.length;i>0;i--) {
            _strToReturn[i-1] = _strBytes[j++];
        }
        
        return string(_strToReturn);
    } 
}
