const contractAddress = sessionStorage.getItem("contractAddress");

const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

const contract = new web3.eth.Contract(abi, contractAddress);

// const accounts = ["0xa9a7029C99Ac0c356792Ea863BF69b1FB3cF53b8"];
const insaccounts = [sessionStorage.getItem("insaccount")];
const hopaccounts = [sessionStorage.getItem("hopaccount")];
const custPrivateKey =
  "0xedf4c20672581574f0e5be9455992931093b4e5cd09bce19f2b8f2071c7160d0";
const insPrivateKey =
  "0x381af7078d460909e62d44677cf0f905b438d65a4450fd21b6efb477fe58a3d1";

/////////////////////////////////////////////////////////////////////////////////
//Adding the policy created by the company to the customer Apply for insurance page
/////////////////////////////////////////////////////////////////////////////////
const policyIdInput = document.getElementById("policyId-apply");
const policyIdArray = JSON.parse(sessionStorage.getItem("policyIdArray"));
// Declaring function for adding new policy
async function addNewPolicy() {
  const cardContainer = document.getElementById("card-container");

  for (let i = 0; i < policyIdArray.length; i++) {
    const policyId1 = policyIdArray[i];
    const policyId = parseInt(policyId1);
    const result = await contract.methods.policiesAvailable(policyId).call();
    const companyName = result.insuranceCompanyName;
    const policyName = result.policyName;
    const premiumtobepaid = result.premiumtobepaid;
    const suminsuredbypolicy = result.suminsuredbypolicy;
    const card = document.createElement("div");
    card.className = "card";
    card.innerHTML = `
        <h2>${policyName}</h2>
        <p>${companyName}</p>
        <p class="policyid">Policy ID: ${policyId}</p>
        <p>Premium Amount: ${premiumtobepaid}</p>
        <p>Amount Insured: ${suminsuredbypolicy}</p>
        <button class="apply-button" onclick="applyForInsurance()">Apply</button>
      `;
    cardContainer.appendChild(card);
  }
}
//Eventlistener that calls the addnewpolicy function.
document.addEventListener("DOMContentLoaded", addNewPolicy);
/////////////////////////////////////////////////////////////////////////////////
//Verifying the added policy when applying for them
//This works when we click on the "Apply" button in dynamicaly created card of policy details
//Works after the applying for insurance to smartcontract
//Have modifier in solidity saying only company can verify the patients
/////////////////////////////////////////////////////////////////////////////////
async function verifyPatient(patientAddress) {
  try {
    const result = await contract.methods
      .VerifyPatient(patientAddress)
      .send({ from: insaccounts[0], gas: "200000" });

    console.log("Patient verification successful.");
    alert("Patient verification successful.");
    console.log(result);
  } catch (error) {
    console.error("Error verifying patient:", error);
    alert("Error verifying patient");
  }
}
/////////////////////////////////////////////////////////////////////////////////
//Applying for the added policy
//Calls applyforinsurance method in solidity code
//premiumcount_policyindex array is called for checking policy is applied only once by one customer
/////////////////////////////////////////////////////////////////////////////////
async function applyForInsurance() {
  // calling the nearest card value;
  const cardContainer = event.target.closest(".card");
  const policyIdElement = cardContainer.querySelector(".policyid");
  const policyId1 = policyIdElement.textContent.split(": ")[1];
  //array declaration
  const policyId = parseInt(policyId1);
  const premiumcount = JSON.parse(sessionStorage.getItem("premiumcount")) || [];
  const premiumcount_policyindex =
    JSON.parse(sessionStorage.getItem("premiumcount_policyindex")) || [];
  //if condition for restricting duplicate apply
  if (!premiumcount_policyindex.includes(policyId)) {
    premiumcount.push(0);
    sessionStorage.setItem("premiumcount", JSON.stringify(premiumcount));
    premiumcount_policyindex.push(policyId);
    console.log(premiumcount);
    console.log(premiumcount_policyindex);
    sessionStorage.setItem(
      "premiumcount_policyindex",
      JSON.stringify(premiumcount_policyindex)
    );

    try {
      const accounts = await web3.eth.getAccounts();

      const result = await contract.methods
        .applyforinsurance(policyId)
        .send({ from: accounts[0], gas: "2000000" }); //Applyind for insurance using policy details and customers address

      console.log("Insurance application successful.");
      alert("Insurance application successful.");
      console.log(result);
      //Varification of the patient is done
      verifyPatient(accounts[0]);
    } catch (error) {
      console.error("Error applying for insurance:", error);
      alert("Error applying for insurance:");
    }
  } else {
    alert("already applied!");
  }
}
/////////////////////////////////////////////////////////////////////////////////
//Beggining of preparation of functions for premium paying function
/////////////////////////////////////////////////////////////////////////////////
//input and buttons
const policyIdInput1 = document.getElementById("policyId-pay");
const senderBalanceDisplay = document.getElementById("senderBalance");
const receiverBalanceDisplay = document.getElementById("receiverBalance");
//function for getting balance of sender and receiver
async function getAccountBalance(address) {
  const balance = await web3.eth.getBalance(address);
  return web3.utils.fromWei(balance, "ether");
}
//function for geting policy datails using the input policy ID
async function getPolicyDetails(policyId) {
  const result = await contract.methods.policiesAvailable(policyId).call();
  return {
    alreadyExists: result.alreadyexits,
    policyName: result.policyName,
    policyId: result.policyId,
    insuranceCompanyRegNum: result.insuraceCompanyregnum,
    insuranceCompanyName: result.insuranceCompanyName,
    insuranceCompanyAddress: result.insuranceCompanyAddress,
    premiumToBePaid: result.premiumtobepaid,
    sumInsuredByPolicy: result.suminsuredbypolicy,
  };
}
/////////////////////////////////////////////////////////////////////////////////
//Event listener that calls the function to print the details of the policy that we are
//applying for. A div is dynamicaly created that restricts the payment of policy value upto
//the sum insured by disabling the payment buton after the limit
/////////////////////////////////////////////////////////////////////////////////
document
  .getElementById("submit-premiumpay")
  .addEventListener("click", async function () {
    // const policyIdInput = document.getElementById("policyIdInput");
    // const policyId = parseInt(policyIdInput.value);
    // const result = await contract.methods.policiesAvailable(policyId).call();
    // const companyName = result.insuranceCompanyName;
    // const policyName = result.policyName;
    // const premiumtobepaid = result.premiumtobepaid;
    // const suminsuredbypolicy = result.suminsuredbypolicy;
    // const premiumcount = JSON.parse(sessionStorage.getItem("premiumcount"));
    // const premiumcount_policyindex = JSON.parse(
    //   sessionStorage.getItem("premiumcount_policyindex")
    // );
    // const indexs = premiumcount_policyindex.indexOf(policyId);
    // const totalpremiumpaid = premiumtobepaid * premiumcount[indexs];
    // const premiumpaydetails = document.getElementById("premiumpay-details");
    const result = await contract.methods.policiesAvailable(policyId).call();
    const companyName = result.insuranceCompanyName;
    const policyName = result.policyName;
    const premiumtobepaid = result.premiumtobepaid;
    const suminsuredbypolicy = result.suminsuredbypolicy;
    const premiumcount = JSON.parse(sessionStorage.getItem("premiumcount"));
    const premiumcount_policyindex = JSON.parse(
      sessionStorage.getItem("premiumcount_policyindex")
    );
    const indexs = premiumcount_policyindex.indexOf(policyId);
    const totalpremiumpaid = premiumtobepaid * premiumcount[indexs]; //total valye paid up until now
    if (totalpremiumpaid >= suminsuredbypolicy) {
      premiumpaydetails.innerHTML = `
    <p>Policy name: ${policyName}</p>
    <p>Company name: ${companyName}</p>
    <p>Monthly premium: ${premiumtobepaid}</p>
    <p>Sum insured by policy: ${suminsuredbypolicy}</p>
    <p>Total premium paid: ${suminsuredbypolicy}</p>
  `;
      alert("Sum insured already reached");
    } else {
      premiumpaydetails.innerHTML = `
    <p>Policy name: ${policyName}</p>
    <p>Company name: ${companyName}</p>
    <p>Monthly premium: ${premiumtobepaid}</p>
    <p>Sum insured by policy: ${suminsuredbypolicy}</p>
    <p>Total premium paid: ${totalpremiumpaid}</p>
  `;
      document.getElementById("premiumbutton").style.visibility = "visible";
    }
  });
/////////////////////////////////////////////////////////////////////////////////
//Function for paying premium it works as long as the sum insured is not reached.
//After claiming you can apply for the policy again and pay premium from start.
//Ether transaction happens
//sender is the customer wallet address
//receiver is the ins_company wallet address
//the transaction is signed using the senders private key
/////////////////////////////////////////////////////////////////////////////////
async function payPremium(policyId) {
  // const policyId = parseInt(policyIdInput1.value);
  const premiumcount = JSON.parse(sessionStorage.getItem("premiumcount"));
  const premiumcount_policyindex = JSON.parse(
    sessionStorage.getItem("premiumcount_policyindex")
  );
  const indexs = premiumcount_policyindex.indexOf(policyId);
  premiumcount[indexs] += 1;
  sessionStorage.setItem("premiumcount", JSON.stringify(premiumcount));
  try {
    //Sender address and receiver address are specified
    const accounts = await web3.eth.getAccounts();
    const senderAddress = accounts[0];
    const senderPrivateKey = custPrivateKey;
    const senderBalanceBefore = await getAccountBalance(senderAddress);
    console.log("Sender balance before:", senderBalanceBefore);
    const policyDetails = await getPolicyDetails(policyId);
    const receiverAddress = policyDetails.insuranceCompanyAddress;
    console.log("receiver address", receiverAddress);
    const receiverBalanceBefore = await getAccountBalance(receiverAddress);
    console.log("receiver balance before:", receiverBalanceBefore);
    console.log(policyDetails.premiumToBePaid);
    //The transaction is signed
    const signedTx = await web3.eth.accounts.signTransaction(
      {
        from: senderAddress,
        to: receiverAddress,
        value: policyDetails.premiumToBePaid,
        gas: 500000,
      },
      senderPrivateKey
    );
    //Obtaining the transaction hash
    const result = await web3.eth.sendSignedTransaction(
      signedTx.rawTransaction
    );
    //premium payoing function for confiriming the payment in solidity code is called
    const result2 = await contract.methods.paypremium(
      receiverAddress,
      policyDetails.premiumToBePaid
    );
    console.log(result2);
    console.log("Transaction hash", result.transactionHash);
    console.log("Premium payment successful.");
    alert("Premium payment successful.");
    const senderBalanceAfter = await getAccountBalance(senderAddress);
    const receiverBalanceAfter = await getAccountBalance(receiverAddress);
    console.log(result);
    //Sender and receiver balance are printed
    senderBalanceDisplay.textContent = `Sender Balance: ${senderBalanceBefore} ETH (Before) -> ${senderBalanceAfter} ETH (After)`;
    receiverBalanceDisplay.textContent = `Receiver Balance: ${receiverBalanceBefore} ETH (Before) -> ${receiverBalanceAfter} ETH (After)`;
  } catch (error) {
    console.error("Error paying premium:", error);
    alert("Error paying premium:");
  }
}
/////////////////////////////////////////////////////////////////////////////////
//Event listener for premium paying function
/////////////////////////////////////////////////////////////////////////////////
document
  .getElementById("premiumbutton")
  .addEventListener("click", async function () {
    const policyIdInput = document.getElementById("policyIdInput");
    const policyId = parseInt(policyIdInput.value);
    await payPremium(policyId);
  });

/////////////////////////////////////////////////////////////////////////////////
//Event listener that calls the function to displaying the claim details
//If total payment of premium is greater than bill amount the bill amount is paid
//else only paid premium amount is reimbursed
/////////////////////////////////////////////////////////////////////////////////
document.getElementById("submit").addEventListener("click", async function () {
  const policyIdInput = document.getElementById("policyIdInput");
  const billIdInput = document.getElementById("billIdInput");

  const policyId = parseInt(policyIdInput.value);
  const billId = parseInt(billIdInput.value);

  const result = await contract.methods.policiesAvailable(policyId).call();
  const companyName = result.insuranceCompanyName;
  const policyName = result.policyName;
  const premiumtobepaid = result.premiumtobepaid;
  const billdetails = await contract.methods.billmapping(billId).call();
  const billamount = billdetails.amount;
  const premiumcount = JSON.parse(sessionStorage.getItem("premiumcount"));
  const premiumcount_policyindex = JSON.parse(
    sessionStorage.getItem("premiumcount_policyindex")
  );
  const indexs = premiumcount_policyindex.indexOf(policyId);
  const totalpremiumpaid = premiumtobepaid * premiumcount[indexs];
  if (totalpremiumpaid >= billamount) {
    const claimdetails = document.getElementById("claim-details");
    claimdetails.innerHTML = `
    <p>Policy name: ${policyName}</p>
    <p>Company name: ${companyName}</p>
    <p>Monthly premium: ${premiumtobepaid}</p>
    <p>Total premium paid: ${totalpremiumpaid}</p>
    <p>Bill Amount: ${billamount}</p>
    <p>Claim Amount: ${billamount}</p>
    `;
  } else {
    const claimdetails = document.getElementById("claim-details");
    claimdetails.innerHTML = `
      <p>Policy name: ${policyName}</p>
      <p>Company name: ${companyName}</p>
      <p>Monthly premium: ${premiumtobepaid}</p>
      <p>Total premium paid: ${totalpremiumpaid}</p>
      <p>Bill Amount: ${billamount}</p>
      <p>Claim Amount: ${totalpremiumpaid}</p>
      `;
  }
  document.getElementById("claimButton").style.visibility = "visible";
});
/////////////////////////////////////////////////////////////////////////////////
//Event listener that calls the function that disburst the claim
//The soldity code have requirmrnts like only valied policy id can claim
//only once a bill can be claimed
/////////////////////////////////////////////////////////////////////////////////
document
  .getElementById("claimButton")
  .addEventListener("click", async function () {
    const policyIdInput = document.getElementById("policyIdInput");
    const billIdInput = document.getElementById("billIdInput");

    const policyId = parseInt(policyIdInput.value);
    const billId = parseInt(billIdInput.value);

    await applyForClaim(policyId, billId);
  });
/////////////////////////////////////////////////////////////////////////////////
// Function to apply for claim
/////////////////////////////////////////////////////////////////////////////////
async function applyForClaim(policyId, billId) {
  try {
    const accounts = await web3.eth.getAccounts();
    const billdetails = await contract.methods.billmapping(billId).call();
    const billamount = billdetails.amount;
    const premiumcount = JSON.parse(sessionStorage.getItem("premiumcount"));
    const premiumcount_policyindex = JSON.parse(
      sessionStorage.getItem("premiumcount_policyindex")
    );
    const indexs = premiumcount_policyindex.indexOf(policyId);
    const policydetails = await contract.methods
      .policiesAvailable(policyId)
      .call();
    const premiumamount = policydetails.premiumtobepaid;
    const premiumpaidupuntilnow = premiumamount * premiumcount[indexs];
    let amountpaid = 0;
    if (premiumpaidupuntilnow >= billamount) {
      amountpaid = billamount;
    } else {
      amountpaid = premiumpaidupuntilnow;
    }
    const result = await contract.methods
      .applyforclaim(accounts[0], policyId, billId)
      .send({ from: accounts[0], gas: "500000" });
    console.log(
      "Claim applied successfully. Transaction:",
      result.transactionHash
    );
    const customerdetails = await contract.methods
      .customerData(accounts[0])
      .call();
    const claimverification = await contract.methods
      .verifyCLaim(customerdetails.claimId, amountpaid)
      .send({ from: insaccounts[0], gas: "500000" });

    console.log(
      "Claim verified successfully. Transaction:",
      claimverification.transactionHash
    );
    //sender and receiver address are assigned
    const recAddress = accounts[0];
    const sendAddress = insaccounts[0];
    const sendPrivateKey = insPrivateKey;
    const recAddressBalanceBefore = await getAccountBalance(recAddress);
    //transaction is signed using ins_company's private key
    const signedTx = await web3.eth.accounts.signTransaction(
      {
        from: sendAddress,
        to: recAddress,
        value: amountpaid,
        gas: 2000000,
      },
      sendPrivateKey
    );
    //Signed transaction is send
    const distresult = await web3.eth.sendSignedTransaction(
      signedTx.rawTransaction
    );
    const recAddressBalanceAfter = await getAccountBalance(recAddress);
    console.log("Distributted");
    console.log(distresult);
    const recerBalance = document.getElementById("recerBalance");
    recerBalance.textContent = `Receiver Balance: ${recAddressBalanceBefore} ETH (Before) -> ${recAddressBalanceAfter} ETH (After)`;
  } catch (error) {
    console.error("Error applying for claim:", error);
  }
}
