pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract Shipment {
 
 /*
  //Future enhancements to have separate objects for each entity
  
    struct Seller {
        string id;
        string location;
    }
    
    struct Buyer {
        string id;
        string location;
    }
    
    struct LogisticsProvider {
        string id;
        string location;
    }
  */
  
    struct TimeRaster {
        string timeStamp;
        string temperatureReading;
    }
    
    struct ShipmentDetails {
        uint shipmentID;
        string temperature;
        string sellerID;
        string buyerID;
        string logisticsProviderID;
        string sellerLocation;
        string buyerLocation;
        ShipmentStatus shipStatus;
        //mapping (uint => TimeRaster[]) timeRaster; // time ==> temperature in °C
        //TimeRaster[] timeRaster;
    }
    
    enum ShipmentStatus {
        WithSeller,
        InTransit,
        Delivered,
        AcceptedbyBuyer,
        RejectedbyBuyer
    }
    
    uint public shipmentUID = 0;
    
    ShipmentStatus private status;
    TimeRaster[] private tR;
    
    mapping(uint => ShipmentDetails) private shipmentList;
    mapping(uint => TimeRaster[]) private timeRaster;
    
    mapping(address => bool) private sellerList;
    mapping(address => bool) private logisticsProviderList;
    mapping(address => bool) private buyerList;
        
    constructor () public {
        sellerList[address(0x00ca35b7d915458ef540ade6068dfe2f44e8fa733c)] = true;
        logisticsProviderList[address(0x0014723a09acff6d2a60dcdf7aa4aff308fddc160c)] = true;
        buyerList[address(0x004b0897b0513fdc7c541b6d9d7e929c4e5364d2db)] = true;
    }

    modifier inStatus(ShipmentStatus _status) {
        require(status == _status, "Please check the required status for this activity!!!");
        _;
    }
    
    modifier isSeller() {
        require(sellerList[msg.sender],"You are not a seller!!!");
        _;
    }
    
    modifier islogisticsProvider() {
        require(logisticsProviderList[msg.sender],"You are not a logistics provider!!!");
        _;
    }
    
    modifier isBuyer() {
        require(buyerList[msg.sender],"You are not a buyer!!!");
        _;
    }
    
    function getShipmentStatus(uint _shipID) public view returns (ShipmentStatus) {
        ShipmentDetails memory tempShipment = shipmentList[_shipID];
        return tempShipment.shipStatus;
    }
  
  
    function getTimeRaster(uint _shipID) public view returns (TimeRaster[] memory) {
        return timeRaster[_shipID];
    }


    function getShipmentData(uint _shipID) public view returns (
        uint,string memory,string memory,string memory,string memory,string memory, string memory, ShipmentStatus,TimeRaster[] memory) 
    {
        TimeRaster[] memory _ltr = timeRaster[_shipID];
        ShipmentDetails memory tempShipment = shipmentList[_shipID];
        return (
          tempShipment.shipmentID,
          tempShipment.temperature,
          tempShipment.sellerID,
          tempShipment.buyerID,
          tempShipment.logisticsProviderID,
          tempShipment.sellerLocation,
          tempShipment.buyerLocation,
          tempShipment.shipStatus,
          _ltr
        );
    }
    
    // "18°C","s1","b1","l1","bangalore","chennai"
    // seller calls this function to create the shipment details
    function createShipment(
        string memory _temperature, string memory _sID, string memory _bID, string memory _lID, string memory _sloc, string memory _bloc) 
        public isSeller 
    {
        ShipmentDetails memory tempShipment = ShipmentDetails({
            shipmentID: ++shipmentUID,
            temperature: _temperature,
            sellerID: _sID,
            buyerID: _bID,
            logisticsProviderID: _lID,
            sellerLocation: _sloc,
            buyerLocation: _bloc,
            shipStatus: ShipmentStatus.WithSeller
        });
        

        shipmentList[shipmentUID] = tempShipment;
    }
    
    function updateTemperature(uint _shipID, string memory _temperature, string memory _time) public {
        TimeRaster memory tempRaster = TimeRaster({
            timeStamp: _time,
            temperatureReading: _temperature
        });
        
        tR.push(tempRaster);
        timeRaster[_shipID] = tR;
    }
    
    // seller calls this function to ship the product by pressing the button
        function sendShipment(uint _shipID) public isSeller inStatus(ShipmentStatus.WithSeller) {
        ShipmentDetails memory tempShipment = shipmentList[_shipID];
        tempShipment.shipStatus = ShipmentStatus.InTransit;
        
        shipmentList[shipmentUID] = tempShipment;
        status = ShipmentStatus.InTransit;
    }

    // logistics provider calls this function to ship the product by pressing the button
    function receiveShipment(uint _shipID) public islogisticsProvider inStatus(ShipmentStatus.InTransit) {
        ShipmentDetails memory tempShipment = shipmentList[_shipID];
        tempShipment.shipStatus = ShipmentStatus.Delivered;
        
        shipmentList[shipmentUID] = tempShipment;
        status = ShipmentStatus.Delivered;
    }

    // buyer calls this function to accept the product
    function acceptShipment(uint _shipID) public isBuyer inStatus(ShipmentStatus.Delivered) {
        ShipmentDetails memory tempShipment = shipmentList[_shipID];
        tempShipment.shipStatus = ShipmentStatus.AcceptedbyBuyer;
        
        shipmentList[shipmentUID] = tempShipment;
        status = ShipmentStatus.AcceptedbyBuyer;
    }
    
    // buyer calls this function to reject the product
    function rejectShipment(uint _shipID) public isBuyer inStatus(ShipmentStatus.Delivered) {
        ShipmentDetails memory tempShipment = shipmentList[_shipID];
        tempShipment.shipStatus = ShipmentStatus.RejectedbyBuyer;
        
        shipmentList[shipmentUID] = tempShipment;
        status = ShipmentStatus.RejectedbyBuyer;
    }
}
