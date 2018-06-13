pragma solidity ^0.4.24;

contract Lottery {
    address public manager;
    address[] private players;
    
    uint[] private finalBalance;

    constructor() public {
        manager = msg.sender;
    }

    function enter() public payable {
        require(msg.value > 0.01 ether,"contribution should be more than 0.01 ether");
        players.push(msg.sender);
    }

    modifier restricted() {
        require(msg.sender == manager,"Only contract creator can call this functionality");
        _;
    }
    
    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, now, players)));
    }

    function pickWinner() public restricted returns(address){
        uint index = random() % getNoOfPlayers();
        players[index].transfer(address(this).balance);
        finalBalance = getAllBalances();
        address[] memory tempPlayers = new address[](index);
        tempPlayers = getPlayers();
        players = new address[](0);
        return tempPlayers[index]; // return address of winner
    }

    function getPlayers() public restricted view returns (address[]) {
        return players;
    }
    
    function getBalance(address _addr) public restricted view returns (uint) {
        return _addr.balance;
    }
    
    function getContractBalance() public restricted view returns (uint) {
        return address(this).balance;
    }
    
    function getNoOfPlayers() public restricted view returns (uint) {
        return players.length;
    }
    
    function getAllBalances() public restricted view returns (uint[]) {
        uint noOfPlayers = getNoOfPlayers();
        uint[] memory allBalances = new uint[](noOfPlayers);
        for(uint i=0; i < noOfPlayers; i++) {
            allBalances[i] = players[i].balance;
        }
        
        return allBalances;
    }
    
    function getFinalBalance() public restricted view returns (uint[]) {
        return finalBalance;
    }
}
