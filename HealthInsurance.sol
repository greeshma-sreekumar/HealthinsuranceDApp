pragma solidity ^0.8.0;

//import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
contract HealthInsurance {
    address Owner;
    string s = "Null";

    //AggregatorV3Interface internal priceFeed;
    constructor() public // once per contract
    {
        Owner = msg.sender; // value from where current function call came from or address that initiated transaction
        // priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        // policiesAvailable[101] = policy1;
        // policiesAvailable[201] = policy2;
        // policiesAvailable[301] = policy3;
        // AllPolicyID.push(101);
        // AllPolicyID.push(201);
        // AllPolicyID.push(301);
    }

    //function convertUsdToEthAndTransfer(address payable _recipient, uint256 _usdAmount) public payable {
    // Retrieve the latest ETH/USD exchange rate from Chainlink oracle
    // (,int256 price,,,) = priceFeed.latestRoundData();
    // uint256 ethUsdRate = uint256(price);

    // Compute the amount of ETH that can be obtained with the given USD amount
    // uint256 ethAmount = (_usdAmount * 1e18) / ethUsdRate;

    // Transfer the computed ETH amount to the recipient address
    // require(address(this).balance >= ethAmount, "Insufficient balance");
    // _recipient.transfer(ethAmount);
    // }

    /* function getEthPrice() public view returns (uint256) {
        (, int256 price, , ,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        return uint256(price);
    }
    function convertUsdToEth(uint256 usdAmount) public view returns (uint256) {
        uint256 ethPrice = getEthPrice();
        uint256 ethAmount = (usdAmount * 1e18) / ethPrice;
        return ethAmount;
    }*/
    /*function transferEther(address payable _recipient, uint256 _amount) public {
        //require(address(this).balance >= _amount, "Insufficient balance");
        _recipient.transfer(_amount);
    }*/

    // 1. Insurance company registration

    mapping(address => insuranceCompany) public insuranceCompaniesmapping; // adreess->structure mapping to store details of insuranceCompany ,wallet address of company to structure info company
    address[] public insuranceCompanies; //keeps track of all insurance Companies in system
    mapping(uint => insuranceCompany)
        public insuranceCompaniesmappingwithregnum; // regnum to insurance comp structure
    address[] public AllAddress; //all registered address will be in this list

    //details of insuranceCompany
    struct insuranceCompany {
        bool isalreadyexisting;
        string insuranceCompanyName;
        address insuranceCompanyWalletAddress; // for customer to transfer premium
        uint insuranceCompanyAccountBalance; // gets this from Premiums and pays claim amount using this balance
        uint insuranceCompanyregnum;
        string insuranceCompanyPassword;
    }

    function AddressExist(address UserAddress) public view returns (bool) {
        if (AllAddress.length == 0) return false;
        else {
            for (uint i = 0; i < AllAddress.length; i++) {
                if (AllAddress[i] == UserAddress) return true;
            }

            return false;
        }
    } // to check whether the entered address is already present in the all adress array

    // modifier to ensure to ensure only admin can add insurance Companies
    modifier onlyOwner() {
        require(Owner == msg.sender); // if this condition is satisfied the rest of the fun stmnts wil be executed whereever this modofier is used
        _;
    }

    // function to add insurance Companies
    //uint regnum=0;
    function addInsuranceCompany(
        string memory _nameofInsuranceCompany, // mem stores data temp,storage perm ,need more gas
        address _insuranceCompanyWalletAddress,
        uint _insuranceCompanyregnum,
        string memory _insuranceCompanyPassword
    )
        public
        // In real world insuance companies have a registration ID with IRDA
        onlyOwner
        returns (address)
    {
        address insuranceCompanyId = _insuranceCompanyWalletAddress; //genrate insurance Company ID which will be unique for each company

        require(
            !insuranceCompaniesmapping[insuranceCompanyId].isalreadyexisting &&
                !AddressExist(_insuranceCompanyWalletAddress),
            "Address already registered"
        ); // req is error handling function,if true rest of code will be executed,if false second para will be displayed

        uint regnum = _insuranceCompanyregnum;

        insuranceCompany memory newinsuranceCompany = insuranceCompany(
            true,
            _nameofInsuranceCompany,
            _insuranceCompanyWalletAddress,
            0,
            _insuranceCompanyregnum,
            _insuranceCompanyPassword
        );

        insuranceCompaniesmapping[insuranceCompanyId] = newinsuranceCompany;
        insuranceCompaniesmappingwithregnum[regnum] = newinsuranceCompany;
        insuranceCompanies.push(insuranceCompanyId);
        AllAddress.push(_insuranceCompanyWalletAddress); // 2 mappings,array for adress of insur comp,array for all address

        return insuranceCompanyId; // returns unique address of insuranceCompany
    }

    // Insurance Company  Login
    function InsuranceCompanyLogin(
        address _insuranceCompanyWalletAddress,
        string memory _insuranceCompanyPassword
    ) public view returns (int) {
        if (
            insuranceCompaniesmapping[_insuranceCompanyWalletAddress]
                .isalreadyexisting == false
        ) return 0;
        // 0 means IC is not registered
        else {
            string memory ICompany_Password = insuranceCompaniesmapping[
                _insuranceCompanyWalletAddress
            ].insuranceCompanyPassword;

            if (
                bytes(_insuranceCompanyPassword).length !=
                bytes(ICompany_Password).length
            ) return 2;
            // 2 means password is incorrect
            else if (
                sha256(abi.encodePacked(_insuranceCompanyPassword)) ==
                sha256(abi.encodePacked(ICompany_Password))
            )
                //abi.encodePacked -converts into raw bytes that can be undestood b EVM
                return 1;
            // 1 means address and password are correct
            else return 2;
        }
    }

    // 2. Hospital registration and verification

    // mapping(address => bool) public verifiedhospitals; // add hosptals to this mapping after 3 verifications
    mapping(address => hospital) public hospitalmapping; // to map unique address of hospital to all its details
    address[] public hospitals; // to keep track of hospitals
    //address[] public registeredhospitals; //all registered hospitals which are not yet verified will be in this list

    struct hospital {
        bool isalreadyexisting;
        string hospitalName;
        int hospitalregnum;
        address hospitalWalletAddress; // to transfer claim amount
        //int numverifications;
        string hospitalPassword;
        uint hospitalbalance;
        //mapping(address => bool) insurCompWhohaveVerified;
    }

    // function to register a new hospital
    function registerhospital(
        string memory _hospitalName,
        int _hospitalregnum,
        address _hospitalWalletAddress,
        string memory _hospitalPassword
    ) public returns (address) {
        address hospitaluniqueaddress = _hospitalWalletAddress;
        //require(msg.sender==_hospitalWalletAddress,"Require to register using same wallet as hospitalWalletAddress");

        require(
            !hospitalmapping[hospitaluniqueaddress].isalreadyexisting &&
                !AddressExist(_hospitalWalletAddress),
            "Address already registered!"
        );

        hospital memory newhospital = hospital(
            true,
            _hospitalName,
            _hospitalregnum,
            _hospitalWalletAddress,
            _hospitalPassword,
            0
        );
        hospitalmapping[_hospitalWalletAddress] = newhospital;
        hospitals.push(_hospitalWalletAddress);
        AllAddress.push(_hospitalWalletAddress);

        return hospitaluniqueaddress;
    }

    //Hospital Login
    function HospitalLogin(
        address _hospitalWalletAddress,
        string memory _hospitalPassword
    ) public view returns (int) {
        if (hospitalmapping[_hospitalWalletAddress].isalreadyexisting == false)
            return 3;
        // 0 means hospital is not registered
        /* else if(verifiedhospitals[_hospitalWalletAddress]==false)
                            return 3; */
        // 3 means hospital has registered but not yet verified by ICs
        else {
            string memory Hospital_Password = hospitalmapping[
                _hospitalWalletAddress
            ].hospitalPassword;

            if (
                bytes(_hospitalPassword).length !=
                bytes(Hospital_Password).length
            ) return 2;
            // 2 means password is incorrect
            else if (
                sha256(abi.encodePacked(_hospitalPassword)) ==
                sha256(abi.encodePacked(Hospital_Password))
            ) return 1;
            // 1 means correct address and password
            else return 2;
        }
    }

    /*modifier onlyInsuranceCompany()
    {
        require(insuranceCompaniesmapping[msg.sender].isalreadyexisting,"Only Insurance Company can verify");
        _;
    }
    
    modifier onlyOnce(address _hospitaladdress)
    {
        require(hospitalmapping[_hospitaladdress].insurCompWhohaveVerified[msg.sender]==false,"Can verify only once");
        _;
    }

    function verifyhospital(address _hospitaladdress) public onlyInsuranceCompany onlyOnce(_hospitaladdress)
    { 
        //onlyInsurance Company can verify
        hospitalmapping[_hospitaladdress].insurCompWhohaveVerified[msg.sender]=true;

        hospitalmapping[_hospitaladdress].numverifications++;
        if(hospitalmapping[_hospitaladdress].numverifications>=3) // add hospital to verifiedhospitals mapping
        {
            verifiedhospitals[_hospitaladdress]=true;
            uint index=0;
            
            for (; index<registeredhospitals.length; index++) 
            {
                if(registeredhospitals[index]==_hospitaladdress)
                    break;
                else{}
            }
            

            if(registeredhospitals.length>1)
            {
                registeredhospitals[index] = registeredhospitals[registeredhospitals.length - 1];
                delete registeredhospitals[registeredhospitals.length - 1];
                registeredhospitals.length--;
            }
            
            else delete registeredhospitals[index];
         }
    }*/

    // 3. Customer registration
    mapping(address => customer) public customerData; // mapping to store customer Data
    address[] public AllCustomers;

    struct customer {
        bool alreadyexits;
        string customerName;
        address customerWalletAddress;
        string CustomerPassword;
        int policyId;
        uint premiumdue;
        uint totalpaid;
        //bool paidpremium;
        uint suminsuredbypolicy;
        // bool appliedForClaim;
        int billId;
        //bool claimSettled;
        int claimId;
        uint inscmpnyid;
        bool verifiedUser;
    }

    //Function to register to the system
    function registerasacustomer(
        string memory _customerName,
        address _customerWalletAddress,
        string memory _CustomerPassword
    ) public {
        require(
            !customerData[_customerWalletAddress].alreadyexits &&
                !AddressExist(_customerWalletAddress),
            "Address already registered"
        );

        customer memory newcustomer = customer(
            true,
            _customerName,
            _customerWalletAddress,
            _CustomerPassword,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            false
        );

        customerData[_customerWalletAddress] = newcustomer;
        AllAddress.push(_customerWalletAddress);
        AllCustomers.push(_customerWalletAddress);
    }

    // Customer Login
    function CustomerLogin(
        address _customerWalletAddress,
        string memory _CustomerPassword
    ) public view returns (int) {
        if (customerData[_customerWalletAddress].alreadyexits == false)
            return 0;
        // 0 means customer is not registered
        else {
            string memory Customer_Password = customerData[
                _customerWalletAddress
            ].CustomerPassword;

            if (
                bytes(_CustomerPassword).length !=
                bytes(Customer_Password).length
            ) return 2;
            // password is incorrect
            else if (
                sha256(abi.encodePacked(_CustomerPassword)) ==
                sha256(abi.encodePacked(Customer_Password))
            ) return 1;
            //1 means valid login credentials
            else return 2;
        }
    }

    //4. Creating new Policies by Insurance Company and policy structure
    mapping(int => policy) public policiesAvailable; // policyid => policy details
    int[] public AllPolicyID;

    struct policy {
        bool alreadyexits;
        string policyName;
        int policyId;
        uint insuraceCompanyregnum;
        string insuranceCompanyName;
        address insuranceCompanyAddress; // the insuranceCompany company providing the policy
        uint premiumtobepaid;
        uint suminsuredbypolicy;
    }

    // Adding details of Policies

    // policy policy1 =
    //     policy(
    //         true,
    //         "Family Floater Policy",
    //         101,
    //         1,
    //         "Jeevan Insurance",
    //         0xCF3C77002B6D9F10bD1AADba66AdfaFf804c18c1,
    //         20000000,
    //         500000
    //     );

    // policy policy2 =
    //     policy(
    //         true,
    //         "Critical Insurance Policy",
    //         201,
    //         1,
    //         "Health Plus Insurance",
    //         0xCF3C77002B6D9F10bD1AADba66AdfaFf804c18c1,
    //         45000000,
    //         6000000
    //     );

    // policy policy3 =
    //     policy(
    //         true,
    //         "ABC Policy",
    //         301,
    //         2,
    //         "Star Health Insurance",
    //         0x57297DeDBd3e39fa3AacF83c3137503bE5003Ea2,
    //         45000000,
    //         6000000
    //     );

    modifier onlyInusranceCompanyAddingPolicy(
        address _insuranceCompanyWalletAddress,
        uint _ICregnum
    ) {
        require(
            msg.sender == _insuranceCompanyWalletAddress &&
                insuranceCompaniesmapping[_insuranceCompanyWalletAddress]
                    .isalreadyexisting ==
                true &&
                insuranceCompaniesmapping[_insuranceCompanyWalletAddress]
                    .insuranceCompanyregnum ==
                _ICregnum,
            "Only insurance Company whose wallet address is passed as argument can use this function"
        );

        _;
    }

    function addnewpolicy(
        string memory _policyName,
        int _policyId,
        uint _ICregnum,
        address _insuranceCompanyWalletAddress,
        uint _premiumtobepaid,
        uint _suminsuredbypolicy
    )
        public
        onlyInusranceCompanyAddingPolicy(
            _insuranceCompanyWalletAddress,
            _ICregnum
        )
    {
        string
            memory _insuraceCompanyname = insuranceCompaniesmappingwithregnum[
                _ICregnum
            ].insuranceCompanyName;

        require(
            !policiesAvailable[_policyId].alreadyexits,
            "Policy with the sameid exists already"
        );
        policy memory newpolicy = policy(
            true,
            _policyName,
            _policyId,
            _ICregnum,
            _insuraceCompanyname,
            _insuranceCompanyWalletAddress,
            _premiumtobepaid,
            _suminsuredbypolicy
        );
        policiesAvailable[_policyId] = newpolicy;
        AllPolicyID.push(_policyId);
    }

    //5. Customer Applies for Policies Available by paying Premiums

    //function to apply for a policy, while applying user has to compulsarily pay the premium for the application to be successfull
    function applyforinsurance(int policyId) public {
        require(
            customerData[msg.sender].alreadyexits,
            "You need to register first"
        );
        require(
            policiesAvailable[policyId].alreadyexits,
            "No such policy exists!!!"
        );

        customerData[msg.sender].policyId = policyId;
        customerData[msg.sender].suminsuredbypolicy = policiesAvailable[
            policyId
        ].suminsuredbypolicy;
        customerData[msg.sender].premiumdue = policiesAvailable[policyId]
            .premiumtobepaid;
        customerData[msg.sender].inscmpnyid = policiesAvailable[policyId]
            .insuraceCompanyregnum;
    }

    modifier onlyTiedICompany(address _PatientAddress) {
        int Policy_ID = customerData[_PatientAddress].policyId;
        require(
            policiesAvailable[Policy_ID].insuranceCompanyAddress ==
                insuranceCompaniesmapping[msg.sender]
                    .insuranceCompanyWalletAddress,
            "Only Insurance Company of policy applied can verify"
        );
        _;
    }

    function VerifyPatient(
        address _PatientAddress
    ) public onlyTiedICompany(_PatientAddress) {
        require(
            customerData[_PatientAddress].policyId != 0,
            "Not yet Applied for policy"
        );
        customerData[_PatientAddress].verifiedUser = true;
    }

    function paypremium(
        address payable insaddress,
        uint _premiumtobepaid
    ) public returns (bool) {
        require(
            customerData[msg.sender].policyId != 0,
            "Not Applied for Policy"
        );
        require(
            customerData[msg.sender].verifiedUser == true,
            " Application not yet verified by Insurance Company"
        );
        //uint256 eth= convertUsdToEth(_premiumtobepaid);
        //transferEther(_insuranceCompanyWalletAddress,eth);
        //insaddress.transfer(eth);
        customerData[msg.sender].totalpaid =
            customerData[msg.sender].totalpaid +
            _premiumtobepaid;
        insuranceCompaniesmappingwithregnum[customerData[msg.sender].inscmpnyid]
            .insuranceCompanyAccountBalance =
            insuranceCompaniesmappingwithregnum[
                customerData[msg.sender].inscmpnyid
            ].insuranceCompanyAccountBalance +
            _premiumtobepaid;
        // convertUsdToEthAndTransfer(insaddress,_premiumtobepaid);
        //customerData[msg.sender].paidpremium=true;

        return true;
    }

    //6. hospital generates bill for patient when patient goes for some treatment

    struct bill {
        int billId;
        uint amount;
        address patientAddress;
        address _hospitalwalletaddress;
        string description;
        bool claimsettled;
        // attachments of bills/ tests
    }

    int billId = 0;
    mapping(int => bill) public billmapping;

    modifier onlyHospital() {
        require(
            hospitalmapping[msg.sender].isalreadyexisting,
            "Only hosptals can genrate bill"
        );
        _;
    }

    function generatebBillforpatient(
        address _patientAddress,
        uint _amount,
        string memory _description
    ) public onlyHospital {
        billId += 1;
        bill memory newBill = bill(
            billId,
            _amount,
            _patientAddress,
            msg.sender,
            _description,
            false
        );
        customerData[_patientAddress].billId = billId;
        billmapping[billId] = newBill;
    }

    // 7. Customer claims Insurance using applyforclaim function and a claimId is genrated linking all details to a claim struct

    struct claim {
        bool exists;
        int claimId;
        int billId;
        uint amount;
        string description;
        bool claimApproved;
        bool claimSettled;
        uint settlementamount;
        address hospitalWalletAddress;
        address insuranceCompanyAddress; // added for modifier onlyTiedInsuraceCompany
        address customerWalletAddress;
    }

    int claimId = 0;
    mapping(int => claim) public claims; // storing all claims(ClaimId => Claim details)
    mapping(address => int[]) public claimsLinkedtoInsuranceCompany; // maybe useful for frontend

    function applyforclaim(
        address _customerWalletAddress,
        int _policyId,
        int _billId
    ) public {
        require(
            customerData[_customerWalletAddress].policyId == _policyId,
            "Invalid Policy Id !!"
        );
        //require(customerData[_customerWalletAddress].premiumdue==true,"Premium Not Paid");
        require(
            customerData[_customerWalletAddress].billId != 0,
            "Bill Not generated"
        );
        require(
            !(billmapping[billId].claimsettled == true),
            "Already disbursed with this billid!!"
        );

        //customerData[_customerWalletAddress].appliedForClaim=true;

        claimId += 1;

        customerData[_customerWalletAddress].claimId = claimId;
        claim memory newClaim = claim(
            true,
            claimId,
            billmapping[_billId].billId,
            billmapping[_billId].amount,
            billmapping[_billId].description,
            false,
            false,
            0,
            billmapping[_billId]._hospitalwalletaddress,
            policiesAvailable[_policyId].insuranceCompanyAddress,
            _customerWalletAddress
        );

        claims[claimId] = newClaim; // adds the claim to the claim mapping
        address LinkedICAddress = policiesAvailable[_policyId]
            .insuranceCompanyAddress;
        claimsLinkedtoInsuranceCompany[LinkedICAddress].push(claimId);
    }

    //8. Insurance Company verifies and disburses the claim amount

    modifier onlyTiedInsuraceCompany(int _claimId) {
        require(
            claims[_claimId].insuranceCompanyAddress == msg.sender,
            "Functionality only for company providing the policy"
        );
        _;
    }

    //Only the provider of the policy can verify the claim and allot a settlementamount
    function verifyCLaim(
        int _claimId,
        uint _settlementamount
    ) public onlyTiedInsuraceCompany(_claimId) {
        require(claims[_claimId].exists == true, "The Claim does not exist");
        claims[_claimId].settlementamount = _settlementamount;
        claims[_claimId].claimApproved = true; //claim is verified
    }

    // The decided settlementamount is paid to the customer by the Insurance Company
    function DisburseClaimamount(
        address payable hosaddress,
        int _claimId
    ) public payable onlyTiedInsuraceCompany(_claimId) {
        require(
            !claims[_claimId].claimSettled,
            "Claim has already been settled"
        );
        require(claims[_claimId].claimApproved == true, "Claim not verified");
        require(
            customerData[claims[_claimId].customerWalletAddress].totalpaid >
                claims[_claimId].amount,
            "Violated insurance conditions"
        );
        address _customerWalletAddress = claims[claimId].customerWalletAddress;
        //customerData[_customerWalletAddress].claimSettled=true;
        //claims[_claimId].claimSettled=true;
        insuranceCompaniesmappingwithregnum[customerData[msg.sender].inscmpnyid]
            .insuranceCompanyAccountBalance =
            insuranceCompaniesmappingwithregnum[
                customerData[msg.sender].inscmpnyid
            ].insuranceCompanyAccountBalance -
            claims[_claimId].settlementamount;
        // convertUsdToEthAndTransfer(hosaddress,claims[_claimId].settlementamount);
        billmapping[claims[_claimId].billId].claimsettled = true;
        //uint256 eth= convertUsdToEth(claims[_claimId].settlementamount);
        //transferEther(claims[_claimId].hospitalWalletAddress,eth);
        //hosaddress.transfer(eth);
    }

    /*function getRegisteredHospitals() public view returns(address[] memory)
    { 
        return registeredhospitals;
    }
    
    
    function getPolicyArray() public view returns(int[] memory)
    { 
        return AllPolicyID;
    }
    
    function getCustomerAddress() public view returns(address[] memory)
    { 
        return AllCustomers;
    }*/
}
