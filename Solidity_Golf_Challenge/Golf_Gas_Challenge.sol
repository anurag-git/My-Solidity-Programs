pragma solidity 0.4.24;
contract C{
    address O;
    uint D;
    address A;
    uint X;
    constructor(address a){
        O=msg.sender;
        A=a;
        X=5;
    }
    function b() payable{
        require(msg.sender==O);
        D+=msg.value;
    }
    function c(){
        require(block.number%2 == 0);
        uint t=((block.number-1)%100)*D/100;
        A.transfer(t);
        D-=t;
    }
}
