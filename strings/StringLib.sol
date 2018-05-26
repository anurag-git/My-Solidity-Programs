pragma solidity ^0.4.0;

library Strings {
    function concat(string _base, string _value) internal pure returns (string) {
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
    
    function strcmp(string _firstStr, string _secondStr) internal pure returns (uint) {
        bytes memory _firstBytes = bytes(_firstStr);
        bytes memory _secondBytes = bytes(_secondStr);
        
        uint i;
        
        for(i=0;i<_firstBytes.length;i++) {
            if(_firstBytes[i] == _secondBytes[i])
                continue;
        }
    
        if(i == _secondBytes.length)
            return 0;
        else
            return 1;
    }
    
    function compareStrings (string a, string b) public pure returns (bool) {
       return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}
