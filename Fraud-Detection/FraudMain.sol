/*
Steps:
1. Call createPatientRecord by patient - 0x004b0897b0513fdc7c541b6d9d7e929c4e5364d2db
2. Call addPrescription by doctor - 0x00ca35b7d915458ef540ade6068dfe2f44e8fa733c
3. Call submitReports by lab - 0x0014723a09acff6d2a60dcdf7aa4aff308fddc160c
4. Call submitClaim by patient - 0x004b0897b0513fdc7c541b6d9d7e929c4e5364d2db
5. Call acceptClaim or rejectClaim by TPA - 0x00dd870fa1b7c4700f2bd7f44238821c26f7392148
6. Call acceptClaim or rejectClaim by insurer - 0x00583031d1113ad414f02576bd6afabfb302140225
7. Call depositClaimAmount by insurer - 0x00583031d1113ad414f02576bd6afabfb302140225
8. Call withdrawClaim by patient - 0x004b0897b0513fdc7c541b6d9d7e929c4e5364d2db
*/

pragma solidity ^0.4.25;

contract FraudMain {
  uint public patientUID=0;
  uint public invoiceUID=0;
  uint public claimUID=0;

/*
  uint private doctorUID=0;
  uint private labUID=0;
  uint private tpaUID=0;
  uint private insurerUID=0;
*/

  enum ClaimStage {
    claimNotSubmitted,
    claimSubmitted,
    claimAccepted,
    claimRejected,
    claimAmountDeposited,
    claimWithdrawn
  }

  struct Person {
    string name;
    string gender;
    string email;
    uint32 age;
    uint pid;
    uint mobile;
  }

/*
  struct Entity {
    uint32 eid;
    uint32 licenseID;
    string name;
    uint32 mobile;
    string email;
  }

  struct Lab {
    Entity e1;
  }

  struct TPA {
    Entity e2;
  }

  struct Insurer {
    Entity e3;
  }

  struct Doctor {
    Person p2;
  }
*/

  struct PatientHealthData {
    string doctorPrescription;
  }

  struct Patient {
    Person pObj;
    Invoice invoiceObj;
    PatientHealthData phd;
  }

  struct Invoice {
    uint invoiceID;
    uint32 invoiceAmountFromLab;
    uint32 invoiceAmountFromPatient;
    uint32 invoiceApprovedAmount;
    Claim patientClaim;
  }

  struct Claim {
    ClaimStage cStage;
    bool isTPAApproved;
    bool isInsurerApproved;
    string reasonForRejectionTPA;
    string reasonForRejectionInsurer;
  }

  // signer list
  // signers can be TPA and Insurer
  mapping (address => bool) private signers;

  mapping (address => bool) private doctorList;
  mapping (address => bool) private labList;
  mapping (address => bool) private patientList;
  mapping (address => bool) private insurerList;
  mapping (address => bool) private tpaList;

  mapping (uint => Patient) private patientIdMap;
  // mapping (uint => Invoice) private invoiceIdMap;
  // dochash => input stringhash
  mapping (string => string) private docHashMap;
  // ipfshash => input stringhash
  mapping (string => string) private IPFShashMap;

  address private contractOwner;
  //Claim public claimFiled;
//  Invoice private invoiceClaimFiled;

  uint ETHER_TO_WEI = 1000000000000000000;

  modifier isSigner() {
    require(signers[msg.sender],"Only TPA or Insurer can sign!!!");
    _;
  }

  modifier isDoctor() {
    require(doctorList[msg.sender],"You are not a doctor!!!");
    _;
  }

  modifier isLab() {
    require(labList[msg.sender], "You are not a lab!!!");
    _;
  }

  modifier isPatient() {
    require(patientList[msg.sender], "You are not a patient!!!");
    _;
  }

  modifier isInsurer() {
    require(insurerList[msg.sender], "You are not a insurer!!!");
    _;
  }

  modifier isTPA() {
    require(insurerList[msg.sender], "You are not a TPA!!!");
    _;
  }

  constructor() public {
    contractOwner = msg.sender;
    //invoiceClaimFiled.patientClaim.cStage = ClaimStage.claimNotSubmitted;

/* for remix
    doctorList[address(0x00ca35b7d915458ef540ade6068dfe2f44e8fa733c)] = true;
    labList[address(0x0014723a09acff6d2a60dcdf7aa4aff308fddc160c)] = true;
    patientList[address(0x004b0897b0513fdc7c541b6d9d7e929c4e5364d2db)] = true;
    insurerList[address(0x00583031d1113ad414f02576bd6afabfb302140225)] = true;

    //signers need to be only TPA and insurer for claim processing
    // TPA
    signers[address(0x00dd870fa1b7c4700f2bd7f44238821c26f7392148)] = true;
    // Insurer
    signers[address(0x00583031d1113ad414f02576bd6afabfb302140225)] = true;
*/

    // for ganache
    patientList[address(0xC0f7A294D15a88DB4ca8D698d8e734c7d55763A9)] = true;
    doctorList[address(0x327C992cE1843Ca21c0D631c59336EB140247Fd4)] = true;
    labList[address(0x9F59a7E25fA467Be7EFe130349efF527177d479b)] = true;
    insurerList[address(0x21A05633Ed5eF839A1D4115077A5ab810f58f6ad)] = true;
    tpaList[address(0xD825eBaF4E462F3990DFe6529FE0118eB1De1480)] = true;

    //signers need to be only TPA and insurer for claim processing
    // TPA
    signers[address(0xD825eBaF4E462F3990DFe6529FE0118eB1De1480)] = true;
    // Insurer
    signers[address(0x21A05633Ed5eF839A1D4115077A5ab810f58f6ad)] = true;
  }

  // "xx",11,"M","333","xyz@gmail.com"
  function createPatientRecord(
    string _name,
    uint32 _age,
    string _gender,
    uint _mobile,
    string _email
  )
    external
    isPatient
  {
      Person memory p_data = Person({
        pid: ++patientUID,
        name: _name,
        age: _age,
        gender: _gender,
        mobile: _mobile,
        email: _email
      });

      Claim memory c_data = Claim({
       cStage: ClaimStage.claimNotSubmitted,
       isTPAApproved: false,
       isInsurerApproved: false,
       reasonForRejectionTPA: "",
       reasonForRejectionInsurer: ""
       //claimInvoice: i_data
     });

     Invoice memory i_data = Invoice({
        invoiceID: 0,
        invoiceAmountFromLab: 0,
        invoiceAmountFromPatient: 0,
        invoiceApprovedAmount: 0,
        patientClaim: c_data
     });

      PatientHealthData memory phd_data = PatientHealthData({
        doctorPrescription: ""
      });

      Patient memory pt_data = Patient({
        pObj: p_data,
        invoiceObj: i_data,
        phd: phd_data
      });

      patientIdMap[patientUID] = pt_data;
  }

  function getPatientDataByID(uint _patientID)
    external
    view
    returns (uint,string,uint32,string,uint,string,string)
  {
      Patient memory pt_data = patientIdMap[_patientID];
      return (
        pt_data.pObj.pid,
        pt_data.pObj.name,
        pt_data.pObj.age,
        pt_data.pObj.gender,
        pt_data.pObj.mobile,
        pt_data.pObj.email,
        pt_data.phd.doctorPrescription
      );
  }

  function getInvoiceDataByID(uint _patientID)
    external
    view
    returns (uint32,uint32,uint,uint32,bool,bool,ClaimStage,string,string)
  {
      Patient memory pt_data = patientIdMap[_patientID];
      return (
        pt_data.invoiceObj.invoiceAmountFromLab,
        pt_data.invoiceObj.invoiceAmountFromPatient,
        pt_data.invoiceObj.invoiceID,
        pt_data.invoiceObj.invoiceApprovedAmount,
        pt_data.invoiceObj.patientClaim.isTPAApproved,
        pt_data.invoiceObj.patientClaim.isInsurerApproved,
        pt_data.invoiceObj.patientClaim.cStage,
        pt_data.invoiceObj.patientClaim.reasonForRejectionTPA,
        pt_data.invoiceObj.patientClaim.reasonForRejectionInsurer
      );
  }

  function addPrescription(uint _patientID,string _prescription)
    external
    isDoctor
  {
    Patient memory p_temp = patientIdMap[_patientID];
    require(p_temp.invoiceObj.patientClaim.cStage == ClaimStage.claimNotSubmitted,
    "Stage should be Claim Not Submitted!!!");

    p_temp.phd.doctorPrescription = _prescription;
    patientIdMap[_patientID] = p_temp;
  }

  // Invoice and lab reports to be submiited by lab
  // To be called when submit button is pressed on UI, which will submit details on UI
  // as well as upload docs i.e Invoice and lab reports
  // invoice ID is generated by lab outside of this contract and passed here

  function submitReports(
    uint _patientID,
    uint32 _invoiceAmount,
    string _dochashInvoice,
    string _inputHashInvoice,
    string _dochashReport,
    string _inputHashReport
  )
    external
    isLab
  {
    Patient memory p_temp = patientIdMap[_patientID];
    require(p_temp.invoiceObj.patientClaim.cStage == ClaimStage.claimNotSubmitted,
    "Stage should be Claim Not Submitted!!!");

    p_temp.invoiceObj.invoiceAmountFromLab = _invoiceAmount;
    p_temp.invoiceObj.invoiceID = ++invoiceUID;

    patientIdMap[_patientID] = p_temp;

    storeDocHash(_dochashInvoice,_inputHashInvoice,_dochashReport,_inputHashReport);
  }


  // claim to be submitted by patient
  // To be called when submit button is pressed on UI, which will submit details on UI
  // as well as upload docs i.e Invoice and lab reports
  function submitClaim(
    uint _patientID,
    uint32 _invoiceAmount,
    uint _invoiceID,
    string _dochashInvoice,
    string _inputHashInvoice,
    string _dochashReport,
    string _inputHashReport
  )
    external
    isPatient
  {
    Patient memory p_temp = patientIdMap[_patientID];
    require(p_temp.invoiceObj.patientClaim.cStage == ClaimStage.claimNotSubmitted,
    "Stage should be Claim Not Submitted!!!");

    p_temp.invoiceObj.invoiceAmountFromPatient = _invoiceAmount;
    p_temp.invoiceObj.invoiceID = _invoiceID;

    p_temp.invoiceObj.patientClaim.cStage = ClaimStage.claimSubmitted;

    patientIdMap[_patientID] = p_temp;

    storeDocHash(_dochashInvoice,_inputHashInvoice,_dochashReport,_inputHashReport);
  }

  // TPA or insurer have to accept claim to get processed
  // this function is just to record your decision,
  // and not to do any analysis on claim,
  // the actual analysis should be done offline before accepting
  function acceptClaim(
    uint _patientID,
    // uint _invoiceID,
    string _approverName
  )
    external
    isSigner
  {
    Patient memory p_temp = patientIdMap[_patientID];
    require(p_temp.invoiceObj.patientClaim.cStage == ClaimStage.claimSubmitted,
    "Stage should be Claim Submitted!!!");

  // update later
  //  require(!p_temp.invoiceObj.isTPAApproved, "TPA has not yet approved !!!");

    if(keccak256(abi.encodePacked(_approverName)) == keccak256(abi.encodePacked("TPA"))) {
      p_temp.invoiceObj.patientClaim.isTPAApproved = true;
    } else if(keccak256(abi.encodePacked(_approverName)) == keccak256(abi.encodePacked("Insurer"))) {
      p_temp.invoiceObj.patientClaim.isInsurerApproved = true;
    }

    if(p_temp.invoiceObj.patientClaim.isInsurerApproved) {
      // if claim approved, means you are approving what paitent is claiming,
      // hence approved amount is set to amount from patient
        p_temp.invoiceObj.invoiceApprovedAmount = patientIdMap[_patientID].invoiceObj.invoiceAmountFromPatient;

        p_temp.invoiceObj.patientClaim.cStage = ClaimStage.claimAccepted;
    }

    patientIdMap[_patientID] = p_temp;
  }

  // TPA or insurer have to accept claim to get processed
  // this function is just to record your decision,
  // and not to do any analysis on claim,
  // the actual analysis should be done offline before rejecting
  function rejectClaim(
    uint _patientID,
    // uint _invoiceID,
    string _rejecterName,
    string _reason
  )
    external
    isSigner
  {
    Patient memory p_temp = patientIdMap[_patientID];
    require(p_temp.invoiceObj.patientClaim.cStage == ClaimStage.claimSubmitted,
    "Stage should be Claim Submitted!!!!!!");

    if(keccak256(abi.encodePacked(_rejecterName)) == keccak256(abi.encodePacked("TPA"))) {
      p_temp.invoiceObj.patientClaim.isTPAApproved = false;
      p_temp.invoiceObj.patientClaim.reasonForRejectionTPA = _reason;
    } else if(keccak256(abi.encodePacked(_rejecterName)) == keccak256(abi.encodePacked("Insurer"))) {
      p_temp.invoiceObj.patientClaim.isInsurerApproved = false;
      p_temp.invoiceObj.patientClaim.reasonForRejectionInsurer = _reason;
    }

    // claim to be rejected finally only if insurer rejects,
    // as he has the final authority
    // 1st way to handle
    // if claim is rejected, amount from lab invoice is approved.

    // 2nd way to handle
    // if claim is rejected, nil amount is approved.
    if(keccak256(abi.encodePacked(_rejecterName)) == keccak256(abi.encodePacked("Insurer"))) {
      if(!p_temp.invoiceObj.patientClaim.isInsurerApproved) {
          p_temp.invoiceObj.invoiceApprovedAmount = 0;
          p_temp.invoiceObj.patientClaim.cStage = ClaimStage.claimRejected;
      }
    }

    patientIdMap[_patientID] = p_temp;
  }

  // deposit can be done only if claim is accepted by insurer
  function depositClaimAmount(uint _patientID)
    external
    payable
    isInsurer
  {
    Patient memory p_temp = patientIdMap[_patientID];
    require(p_temp.invoiceObj.patientClaim.cStage == ClaimStage.claimAccepted,
    "Stage should be Claim Accepted!!!!!!");

    require(msg.value > 1 ether, "Deposit needs to be more than 1 ether");
    require(msg.value >= p_temp.invoiceObj.invoiceAmountFromPatient, "Deposit is less than claim amount from Patient!!!");

    p_temp.invoiceObj.patientClaim.cStage = ClaimStage.claimAmountDeposited;

    patientIdMap[_patientID] = p_temp;
  }

  // Only Patient can call this function,
  // this design is better than sending the claim amount to patient's account
  // to avoid re-entrancy bug
  // He has to check whether TPA has approved or rejected before claim disbursement

  function withdrawClaim(uint _patientID)
    external
    isPatient
  {
    Patient memory p_temp = patientIdMap[_patientID];
    require(p_temp.invoiceObj.patientClaim.cStage == ClaimStage.claimAmountDeposited,
    "Stage should be Claim Amount Deposited!!!");

    //require(i_temp.isTPAApproved, "TPA has not approved the claim!!!");
    //require(i_temp.isInsurerApproved, "Insurer has not approved the claim!!!");

    // convert to weis (i.e. 2 * 10^18)
    //uint amountToDisburse = i_temp.invoiceApprovedAmount * ETHER_TO_WEI;
    uint amountToDisburse = p_temp.invoiceObj.invoiceApprovedAmount * ETHER_TO_WEI;

    msg.sender.transfer(amountToDisburse);

    // add logic to change stage to claimNotSubmitted when claim amount is
    // completed disbursed and no amount remaining, hence no need to call withdrawRemainingClaimAmount
    p_temp.invoiceObj.patientClaim.cStage = ClaimStage.claimWithdrawn;

    patientIdMap[_patientID] = p_temp;
  }


  function getContractBalance() external view returns(uint){
      return address(this).balance;
  }

/*
  function resetClaimStage() external {
    //reset claim stage for new claim
    invoiceClaimFiled.patientClaim.cStage = ClaimStage.claimNotSubmitted;
  }
*/
  // "QmPjPXQgNxAWPbxka1Kg6RrCqfcLowj2dCLpND9E9Hg7TA","23164123a74ff75eb3fabf62527bfbff12174f676248545bf352c1f53b7bbcb3"
  function storeDocHash(
    string _dochashInvoice,
    string _inputHashInvoice,
    string _dochashReport,
    string _inputHashReport
  )
    private
  {
    docHashMap[_inputHashInvoice] = _dochashInvoice;
    docHashMap[_inputHashReport] = _dochashReport;
  }

  function storeIPFSHash(
    string _ipfshashInvoice,
    string _inputHashInvoice,
    string _ipfshashReport,
    string _inputHashReport
  )
  external
  {
    IPFShashMap[_inputHashInvoice] = _ipfshashInvoice;
    IPFShashMap[_inputHashReport] = _ipfshashReport;
  }

  //23164123a74ff75eb3fabf62527bfbff12174f676248545bf352c1f53b7bbcb3
  // provide inputhash returns dochash
  function getDocHash(string _inputHash) external view returns (string) {
    return docHashMap[_inputHash];
  }

  // provide inputhash returns ipfshash
  function getIPFSHash(string _inputHash) external view returns (string) {
    return IPFShashMap[_inputHash];
  }
}
