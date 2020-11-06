pragma solidity ^0.5.0;

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// Refer https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

interface ERC721Interface {
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

  function balanceOf(address _owner) external view returns (uint256);
  function ownerOf(uint256 _tokenId) external view returns (address);
  function transferFrom(address _from, address _to, uint256 _tokenId) external;
  function approve(address _approved, uint256 _tokenId) external;
}

interface ERC721Metadata /* is ERC721 */ {
    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string memory _name);

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string memory _symbol);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
   // function tokenURI(uint256 _tokenId) external view returns (string);
}

contract MyERC721Token is ERC721Interface, ERC721Metadata {
  using SafeMath for uint256;

  event NewCar(uint carId, string _make, string _model, string _engineFuelType, string _engineCapacity, uint256 _yearOfMfg);
  event BurnCar(address tokenOwner, address Zero, uint256 _tokenId);
  
  struct Car {
    string make; // Hyundai, Maruti, Toyota
	string model; // Hyundai i10, Maruti Baleno, 
    string engineFuelType; // Petrol or Diesel or Hybrid
    string engineCapacity; // 1000cc, 1500cc	
	uint256 yearOfMfg; // 2000, 2010
  }

  Car[] cars;

  mapping (uint256 => address) idToOwner;
  mapping (address => uint256) ownerToNFTokenCount;
  mapping (uint256 => address) idToApproval;

  string internal nftName;
  string internal nftSymbol;
  address public contractOwner;
  uint private totalTokenSupply;

  modifier onlyOwner() {
    require(msg.sender == contractOwner);
    _;
  }
	  
  modifier onlyOwnerOf(uint _tokenId) {
    require(msg.sender == idToOwner[_tokenId]);
    _;
  }
  
  modifier validNFToken(uint256 _tokenId) {
    require(idToOwner[_tokenId] != address(0));
    _;
  }
  
  constructor() public {
	contractOwner = msg.sender;
    nftName = "MYToken";
    nftSymbol= "MYT";
    totalTokenSupply = 0;
  }
  
  function name() public view returns (string memory) {
    return nftName;
  }

  function symbol() public view returns (string memory) {
    return nftSymbol;
  }
  
  function balanceOf(address _owner) external view returns (uint256) {
    return ownerToNFTokenCount[_owner];
  }

  function ownerOf(uint256 _tokenId) external view returns (address) {
    return idToOwner[_tokenId];
  }

  function totalSupply() public view returns (uint) {
    return totalTokenSupply;
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) external validNFToken(_tokenId) {
    require(idToOwner[_tokenId] == _from, "ERC721: transfer of token that is not own");
    require(_to != address(0));

    _clearApproval(_tokenId);

    _removeNFToken(_from, _tokenId); // remove the tokenId from "_from" user
    _addNFToken(_to, _tokenId); // add the tokenId to "_to" user

    emit Transfer(_from, _to, _tokenId);
  }
  
  function approve(address _approved, uint256 _tokenId) external onlyOwnerOf(_tokenId) {
    idToApproval[_tokenId] = _approved;
    emit Approval(msg.sender, _approved, _tokenId);
  }
  
  
  function _addNFToken(address _to, uint256 _tokenId) internal {
    require(idToOwner[_tokenId] == address(0));

    idToOwner[_tokenId] = _to;
    ownerToNFTokenCount[_to] = ownerToNFTokenCount[_to].add(1);
  }
  
  function _removeNFToken(address _from, uint256 _tokenId) internal {
    require(idToOwner[_tokenId] == _from);
    ownerToNFTokenCount[_from] = ownerToNFTokenCount[_from] - 1;
    delete idToOwner[_tokenId];
  }
  
  function _clearApproval(uint256 _tokenId) private {
    if (idToApproval[_tokenId] != address(0))
    {
      delete idToApproval[_tokenId];
    }
  }
  
  
  // Note: For testing purpose, not part of ERC721 Token
  // "Hyundai","i10","Petrol","1000cc",2010
  // "Maruti","Baleno","Petrol","1000cc",2020
  function mintCar(
	string memory _make, 
	string memory _model, 
	string memory _engineFuelType,
	string memory _engineCapacity,
	uint256 _yearOfMfg,
	address _to
	) 
	public 
  {
    uint carId = cars.push(Car(_make, _model, _engineFuelType, _engineCapacity, _yearOfMfg));
    
	_addNFToken(_to, carId);
	
	totalTokenSupply = totalTokenSupply.add(1);
	
    emit NewCar(carId, _make, _model, _engineFuelType, _engineCapacity, _yearOfMfg);
  }
  
  function burnCar(uint256 _tokenId) public onlyOwner validNFToken(_tokenId) {
    address tokenOwner = idToOwner[_tokenId];
    
    _clearApproval(_tokenId);
	
    _removeNFToken(tokenOwner, _tokenId);
	
	totalTokenSupply = totalTokenSupply.sub(1);
    
	emit BurnCar(tokenOwner, address(0), _tokenId);
  }
}
