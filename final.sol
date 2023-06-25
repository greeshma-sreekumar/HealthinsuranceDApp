pragma solidity ^0.4.24;

contract HealthInsurance{  
   
    address Owner;
    string s="Null";

    constructor() public
    {
        Owner=msg.sender;
          }

// 1. Insurance company registration 

    mapping(address => insuranceCompany)public insuranceCompaniesmapping; // mapping to store details of insuranceCompany 
    address[] public insuranceCompanies;//keeps track of all insurance Companies in system
    mapping(uint => insuranceCompany) public inusranceCompaniesmappingwithregnum; 
    address[] public AllAddress; //all registered address will be in this list

    //details of insuranceCompany
    struct insuranceCompany{
        bool isalreadyexisting;
        string insuranceCompanyName;
        address insuranceCompanyWalletAddress; // for customer to transfer premium
        int insuranceCompanyAccountBalance; // gets this from Premiums and pays claim amount using this balance
        uint insuranceCompanyregnum;
        string insuranceCompanyPassword;
    }
        
    function AddressExist(address UserAddress) public view returns  (bool)
    {
        if(AllAddress.length ==0)
            return false;
        else
        {
            
            for(uint i=0;i<AllAddress.length;i++)
            {
                if(AllAddress[i]==UserAddress)
                    return true;
            }
            
        return false;
        }
    }
    
    // modifier to ensure to ensure only admin can add insurance Companies
    modifier onlyOwner()
    {
        require (Owner == msg.sender);
        _;
    }

    // function to add insurance Companies
    uint regnum=0;
    function addInsuranceCompany(string memory _nameofInsuranceCompany,
                                 address _insuranceCompanyWalletAddress,
                                 uint _insuranceCompanyregnum,
                                 string _insuranceCompanyPassword
                                 // In real world insuance companies have a registration ID with IRDA
                                 )
                                // onlyOwner
                                public
                                returns(address)
                {
                    address insuranceCompanyId =_insuranceCompanyWalletAddress ; //genrate insurance Company ID which will be unique for each company
    
                    require(!insuranceCompaniesmapping[insuranceCompanyId].isalreadyexisting &&
                            !AddressExist(_insuranceCompanyWalletAddress),
                            "Address already registered"); 

                    regnum =_insuranceCompanyregnum;
                    
                    insuranceCompany memory newinsuranceCompany=insuranceCompany
                                                        (true,
                                                        _nameofInsuranceCompany,
                                                        _insuranceCompanyWalletAddress,
                                                        0,
                                                        regnum,
                                                        _insuranceCompanyPassword
                                                        );
                    
                    insuranceCompaniesmapping[insuranceCompanyId]=newinsuranceCompany;
                    inusranceCompaniesmappingwithregnum[regnum]=newinsuranceCompany;
                    insuranceCompanies.push(insuranceCompanyId);
                    AllAddress.push(_insuranceCompanyWalletAddress);

                    return insuranceCompanyId;// returns unique address of insuranceCompany
                }


    // Insurance Company  Login
    function InsuranceCompanyLogin (address _insuranceCompanyWalletAddress,string  _insuranceCompanyPassword) view public returns(int)
                {
                    
                    if(insuranceCompaniesmapping[_insuranceCompanyWalletAddress].isalreadyexisting == false)
                            return 0; // 0 means IC is not registered 
                    
                    else
                        {
                          string  ICompany_Password= insuranceCompaniesmapping[_insuranceCompanyWalletAddress].insuranceCompanyPassword;

                          if(bytes(_insuranceCompanyPassword).length != bytes(ICompany_Password).length) 
                             return 2; // 2 means password is incorrect
                          else if (sha256(abi.encodePacked(_insuranceCompanyPassword)) == sha256(abi.encodePacked(ICompany_Password)))
                                return 1; // 1 means address and password are correct 
                          else 
                            return 2;
                        }
                }
                
// 2. Hospital registration and verification
    
    mapping(address => bool) public verifiedhospitals; // add hosptals to this mapping after 3 verifications
    mapping(address => hospital) public hospitalmapping; // to map unique address of hospital to all its details
    address[] public hospitals; // to keep track of hospitals
    address[] public registeredhospitals; //all registered hospitals which are not yet verified will be in this list
    
    struct hospital{
        bool isalreadyexisting;
        string hospitalName;
        int hospitalregnum;
        address hospitalWalletAddress; // to transfer claim amount
        int numverifications;
        string hospitalPassword;
        mapping(address => bool) insurCompWhohaveVerified;
    }
    
     // function to register a new hospital 
    function registerhospital (
                            string memory _hospitalName,
                            int _hospitalregnum,
                            address _hospitalWalletAddress,
                            string  _hospitalPassword
                            )
                            public
                            returns (address)
                    {
                          address hospitaluniqueaddress = _hospitalWalletAddress;
                          //require(msg.sender==_hospitalWalletAddress,"Require to register using same wallet as hospitalWalletAddress");
                         
                         require(!hospitalmapping[hospitaluniqueaddress].isalreadyexisting &&
                                 !AddressExist(_hospitalWalletAddress),
                                 "Address already registered!");
                         
                         hospital memory newhospital = hospital( true,
                                                        _hospitalName,
                                                        _hospitalregnum,
                                                        _hospitalWalletAddress,
                                                        0,
                                                        _hospitalPassword
                                                );
                        hospitalmapping[_hospitalWalletAddress]=newhospital;
                        registeredhospitals.push(_hospitalWalletAddress);
                        AllAddress.push(_hospitalWalletAddress);
                        
                        return hospitaluniqueaddress;
                    }

    //Hospital Login
    function HospitalLogin (address _hospitalWalletAddress,string  _hospitalPassword) view public returns(int)
                {
    
                        if (hospitalmapping[_hospitalWalletAddress].isalreadyexisting == false)
                            return 0; // 0 means hospital is not registered 
                        
                        else
                        {
                          string  Hospital_Password= hospitalmapping[_hospitalWalletAddress].hospitalPassword;

                          if(bytes(_hospitalPassword).length != bytes(Hospital_Password).length) 
                             return 2; 
                          else  (sha256(abi.encodePacked(_hospitalPassword)) == sha256(abi.encodePacked(Hospital_Password)));
                                return 1; // 1 means correct address and password
                          
                        }
                }
                
    modifier onlyInsuranceCompany()
    {
        require(insuranceCompaniesmapping[msg.sender].isalreadyexisting,"Only Insurance Company can verify");
        _;
    }
    
    modifier onlyOnce(address _hospitaladdress)
    {
        require(hospitalmapping[_hospitaladdress].insurCompWhohaveVerified[msg.sender]==false,"Can verify only once");
        _;
    }

    
    
// 3. Customer registration
    mapping(address => customer) public customerData; // mapping to store customer Data
    address[] public AllCustomers;

    struct customer{
        bool alreadyexits;
        string customerName;
        address customerWalletAddress;
        string CustomerPassword;
        int policyId;
        uint premiumdue;
        bool paidpremium;
        uint suminsuredbypolicy;
        bool appliedForClaim;
        int billId;
        bool claimSettled;
        int claimId;
        bool verifiedUser;
    }
    
    
    
    //Function to register to the system
    function registerasacustomer(string _customerName,address _customerWalletAddress,string _CustomerPassword) public
    {
        require(!customerData[_customerWalletAddress].alreadyexits &&
                !AddressExist(_customerWalletAddress),
                "Address already registered");
                
        customer memory newcustomer = customer( true,
                                                _customerName,
                                                _customerWalletAddress,
                                                _CustomerPassword,
                                                0,
                                                0,
                                                true,
                                                0,
                                                false,
                                                0,
                                                false,
                                                0,
                                                false
                                                );
                                                
        customerData[_customerWalletAddress]=newcustomer;
        AllAddress.push(_customerWalletAddress);
        AllCustomers.push(_customerWalletAddress);
    }
    
    // Customer Login
    function CustomerLogin (address _customerWalletAddress,string  _CustomerPassword) view public returns(int)
                {
    
                    if(customerData[_customerWalletAddress].alreadyexits== false)
                            return 0; // 0 means customer is not registered 
                        
                    else
                        {  string  Customer_Password= customerData[_customerWalletAddress].CustomerPassword;

                           if(bytes(_CustomerPassword).length != bytes(Customer_Password).length) 
                              return 2; // password is incorrect
                                   
                           else if(sha256(abi.encodePacked(_CustomerPassword)) == sha256(abi.encodePacked(Customer_Password)))
                            return 1; //1 means valid login credentials
                        
                           else return 2;
                        }
                }

//4. Creating new Policies by Insurance Company and policy structure
    mapping(int => policy) public policiesAvailable;// policyid => policy details
    int[] public AllPolicyID;

    struct policy{
        bool alreadyexits;
        string policyName;
        int policyId;
        uint insuraceCompanyregnum;
        string insuranceCompanyName;
        address insuranceCompanyAddress; // the insuranceCompany company providing the policy
        uint premiumtobepaid;
        uint suminsuredbypolicy;
    }
    
    modifier onlyInusranceCompanyAddingPolicy(address _insuranceCompanyWalletAddress,uint _ICregnum)
    {
        require(msg.sender==_insuranceCompanyWalletAddress && 
                insuranceCompaniesmapping[_insuranceCompanyWalletAddress].isalreadyexisting==true &&
                insuranceCompaniesmapping[_insuranceCompanyWalletAddress].insuranceCompanyregnum==_ICregnum,
                "Only insurance Company whose wallet address is passed as argument can use this function");
        
        _;
    }
            


       function addnewpolicy(string memory _policyName,
                              int _policyId,
                              uint _ICregnum,
                              address _insuranceCompanyWalletAddress,
                              uint _premiumtobepaid,
                              uint _suminsuredbypolicy
                              ) 
                        onlyInusranceCompanyAddingPolicy(_insuranceCompanyWalletAddress,_ICregnum)
                        public {
                        
                        string _insuraceCompanyname=inusranceCompaniesmappingwithregnum[_ICregnum].insuranceCompanyName;
                        
                        require(!policiesAvailable[_policyId].alreadyexits,"Policy with the sameid exists already");
                        policy memory newpolicy = policy(true,_policyName,_policyId,_ICregnum,_insuraceCompanyname,_insuranceCompanyWalletAddress,_premiumtobepaid,_suminsuredbypolicy);
                        policiesAvailable[_policyId]=newpolicy;
                        AllPolicyID.push(_policyId);
            }
        
//5. Customer Applies for Policies Available by paying Premiums

    //function to apply for a policy, while applying user has to compulsarily pay the premium for the application to be successfull
    function applyforinsurance(int policyId) payable public{
        require(customerData[msg.sender].alreadyexits,"You need to register first");
        require(policiesAvailable[policyId].alreadyexits,"No such policy exists!!!");
        
        customerData[msg.sender].policyId=policyId;
        customerData[msg.sender].suminsuredbypolicy=policiesAvailable[policyId].suminsuredbypolicy;
        customerData[msg.sender].premiumdue=0;
    }
    
    
             
    modifier onlyTiedICompany(address _PatientAddress) 
    {
        int Policy_ID= customerData[_PatientAddress].policyId;
        require(policiesAvailable[Policy_ID].insuranceCompanyAddress ==insuranceCompaniesmapping[msg.sender].insuranceCompanyWalletAddress ,
        "Only Insurance Company of policy applied can verify");
        _;
    }

    function VerifyPatient(address _PatientAddress) public onlyTiedICompany( _PatientAddress)
    {
        require(customerData[_PatientAddress].policyId != 0, "Not yet Applied for policy");
        customerData[_PatientAddress].verifiedUser=true;
    }   
 
    function paypremium(address _insuranceCompanyWalletAddress,
                        uint _premiumtobepaid
                        )
                        payable
                        external
                
                        returns (bool)
                        {
                           require(customerData[msg.sender].policyId != 0 , "Not Applied for Policy");
                           require(customerData[msg.sender].verifiedUser==true," Application not yet verified by Insurance Company");
                            customerData[msg.sender].paidpremium=true;
                            return true;
                        }

//6. hospital generates bill for patient when patient goes for some treatment

    struct bill{
        int billId;
        int amount;
        address patientAddress;
        address _hospitalwalletaddress;
        string description;
        // attachments of bills/ tests
    }
    
    int billId=0;
    mapping(int => bill) public billmapping;
    
    modifier onlyHospital
    {
        require(verifiedhospitals[msg.sender],"Only hosptals can genrate bill");
        _;
    }
    
    
    function generatebBillforpatient(address _patientAddress,
                                     int _amount,
                                     string _description)
                                    //  onlyHospital
                                     public returns (int)
                                     {
                                         billId+=1;
                                         bill memory newBill=bill(billId,_amount,_patientAddress,msg.sender,_description);
                                         customerData[_patientAddress].billId=billId;
                                         billmapping[billId]=newBill;
                                         return billId;
                                     }
                                     
// 7. Customer claims Insurance using applyforclaim function and a claimId is genrated linking all details to a claim struct

     struct claim {
         bool exists;
        int claimId;
        int billId;
        int amount;
        string description;
        bool claimApproved;
        bool claimSettled;
        uint settlementamount;
        address customerWalletAddress;
        address insuranceCompanyAddress;// added for modifier onlyTiedInsuraceCompany
    }
    
    int claimId=0;
    mapping(int =>claim) public claims ; // storing all claims(ClaimId => Claim details)
    mapping(address=> int[]) public  claimsLinkedtoInsuranceCompany; // maybe useful for frontend

    function applyforclaim(address _customerWalletAddress, int _policyId, int _billId) public
    {
        require(customerData[_customerWalletAddress].policyId==_policyId,"Invalid Policy Id !!" );
        require(customerData[_customerWalletAddress].paidpremium==true,"Premium Not Paid");
        require(customerData[_customerWalletAddress].billId!=0,"Bill Not generated");
        require(customerData[_customerWalletAddress].appliedForClaim==false && customerData[_customerWalletAddress].claimSettled==false,
                "Already Applied for Claim!!") ;

        customerData[_customerWalletAddress].appliedForClaim=true;
        
        claimId+=1;
        
        customerData[_customerWalletAddress].claimId=claimId;
        claim memory newClaim= claim(true,
                                    claimId,
                                    billmapping[_billId].billId,
                                    billmapping[_billId].amount,
                                    billmapping[_billId].description,
                                    false,
                                    false,
                                    0,
                                    _customerWalletAddress,
                                    policiesAvailable[_policyId].insuranceCompanyAddress
                                    );
        
        claims[claimId]=newClaim; // adds the claim to the claim mapping
        address LinkedICAddress=policiesAvailable[_policyId].insuranceCompanyAddress;
        claimsLinkedtoInsuranceCompany[LinkedICAddress].push(claimId);
    }

//8. Insurance Company verifies and disburses the claim amount

    modifier onlyTiedInsuraceCompany(int _claimId)
    {
        require(claims[_claimId].insuranceCompanyAddress==msg.sender,"Functionality only for company providing the policy");
        _;
    }

    //Only the provider of the policy can verify the claim and allot a settlementamount
     function verifyCLaim(int _claimId, uint _settlementamount) onlyTiedInsuraceCompany(_claimId) public
    {
        require(claims[_claimId].exists==true,"The Claim does not exist");
        claims[_claimId].settlementamount=_settlementamount; 
        claims[_claimId].claimApproved=true; //claim is verified
        
    }
    
    // The decided settlementamount is paid to the customer by the Insurance Company
    function DisburseClaimamount(int _claimId) payable onlyTiedInsuraceCompany(_claimId) public
    {   require(!claims[_claimId].claimSettled,"Claim has already been settled");
        require(claims[_claimId].claimApproved==true,"Claim not verified");
        address _customerWalletAddress=claims[claimId].customerWalletAddress;
        customerData[_customerWalletAddress].claimSettled=true;
        claims[_claimId].claimSettled=true;
    }
    
    
    
    
} 