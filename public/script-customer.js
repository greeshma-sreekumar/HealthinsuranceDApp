// const contractAddress = "0x9625dd057CAdFdB78E13731384813AC0Fe6E9A98";

// const { EthereumProvider } = require("ganache");

// const abi = JSON.parse(sessionStorage.getItem("abi"));
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

const policyIdInput = document.getElementById("policyId-apply");
const policyIdArray = JSON.parse(sessionStorage.getItem("policyIdArray"));
// const premiumcount = [];

// const premiumcount_policyindex = [];
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

document.addEventListener("DOMContentLoaded", addNewPolicy);

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

async function applyForInsurance() {
  // const policyId = parseInt(policyIdInput.value);
  const cardContainer = event.target.closest(".card");
  const policyIdElement = cardContainer.querySelector(".policyid");
  const policyId1 = policyIdElement.textContent.split(": ")[1];
  const policyId = parseInt(policyId1);
  const premiumcount = JSON.parse(sessionStorage.getItem("premiumcount")) || [];
  const premiumcount_policyindex =
    JSON.parse(sessionStorage.getItem("premiumcount_policyindex")) || [];
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
        .send({ from: accounts[0], gas: "2000000" });

      console.log("Insurance application successful.");
      alert("Insurance application successful.");
      console.log(result);
      verifyPatient(accounts[0]);
    } catch (error) {
      console.error("Error applying for insurance:", error);
      alert("Error applying for insurance:");
    }
  } else {
    alert("already applied!");
  }
}
// const apply_button = document.getElementsByClassName("apply-button");
// apply_button.addEventListener("click", applyForInsurance);

const policyIdInput1 = document.getElementById("policyId-pay");
const senderBalanceDisplay = document.getElementById("senderBalance");
const receiverBalanceDisplay = document.getElementById("receiverBalance");

async function getAccountBalance(address) {
  const balance = await web3.eth.getBalance(address);
  return web3.utils.fromWei(balance, "ether");
}

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

document
  .getElementById("submit-premiumpay")
  .addEventListener("click", async function () {
    const policyIdInput = document.getElementById("policyIdInput");
    const policyId = parseInt(policyIdInput.value);
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
    const totalpremiumpaid = premiumtobepaid * premiumcount[indexs];
    const premiumpaydetails = document.getElementById("premiumpay-details");
    if (totalpremiumpaid + premiumtobepaid <= suminsuredbypolicy) {
      premiumpaydetails.innerHTML = `
    <p>Policy name: ${policyName}</p>
    <p>Company name: ${companyName}</p>
    <p>Monthly premium: ${premiumtobepaid}</p>
    <p>Sum insured by policy: ${suminsuredbypolicy}</p>
    <p>Total premium paid: ${totalpremiumpaid}</p>
  `;
    } else {
      premiumpaydetails.innerHTML = `
    <p>Policy name: ${policyName}</p>
    <p>Company name: ${companyName}</p>
    <p>Monthly premium: ${premiumtobepaid}</p>
    <p>Sum insured by policy: ${suminsuredbypolicy}</p>
    <p>Total premium paid: ${suminsuredbypolicy}</p>
  `;
    }
    document.getElementById("premiumbutton").style.visibility = "visible";
  });

async function payPremium(policyId) {
  // const policyId = parseInt(policyIdInput1.value);
  const premiumcount = JSON.parse(sessionStorage.getItem("premiumcount"));
  const premiumcount_policyindex = JSON.parse(
    sessionStorage.getItem("premiumcount_policyindex")
  );
  const indexs = premiumcount_policyindex.indexOf(policyId);
  const result = await contract.methods.policiesAvailable(policyId).call();
  const suminsuredbypolicy = result.suminsuredbypolicy;
  const premiumtobepaid = result.premiumtobepaid;
  const totalpremiumpaid = premiumtobepaid * premiumcount[indexs];
  console.log(`premiumcount:${premiumcount[indexs]}`);
  console.log(`totalpremiumpaid:${totalpremiumpaid}`);
  console.log(`premiumtobepaid:${premiumtobepaid}`);
  if (totalpremiumpaid + premiumtobepaid <= suminsuredbypolicy) {
    premiumcount[indexs] += 1;
    sessionStorage.setItem("premiumcount", JSON.stringify(premiumcount));
    console.log("after");
    console.log(`premiumcount:${premiumcount[indexs]}`);

    try {
      const accounts = await web3.eth.getAccounts();
      const senderAddress = accounts[0];
      const senderPrivateKey = custPrivateKey;
      const senderBalanceBefore = await getAccountBalance(senderAddress);
      console.log("Sender balance", senderBalanceBefore);
      const policyDetails = await getPolicyDetails(policyId);
      console.log(policyDetails);
      const receiverAddress = policyDetails.insuranceCompanyAddress;

      // const receiverAddress = insaccounts[0];
      console.log("receiver address", receiverAddress);
      const receiverBalanceBefore = await getAccountBalance(receiverAddress);
      console.log("receiver balance", receiverBalanceBefore);
      console.log(policyDetails.premiumToBePaid);
      const signedTx = await web3.eth.accounts.signTransaction(
        {
          from: senderAddress,
          to: receiverAddress,
          value: policyDetails.premiumToBePaid,
          gas: 500000,
        },
        senderPrivateKey
      );

      const result = await web3.eth.sendSignedTransaction(
        signedTx.rawTransaction
      );
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

      // const premium_paid = sessionStorage.getItem("premium_paid") || [];
      // sessionStorage.setItem(
      //   "contractAddress",
      //   "0x851d3b2e2c91f4cABcaA15075B6db04F58Ce0505"
      // );
      senderBalanceDisplay.textContent = `Sender Balance: ${senderBalanceBefore} ETH (Before) -> ${senderBalanceAfter} ETH (After)`;
      receiverBalanceDisplay.textContent = `Receiver Balance: ${receiverBalanceBefore} ETH (Before) -> ${receiverBalanceAfter} ETH (After)`;
    } catch (error) {
      console.error("Error paying premium:", error);
      alert("Error paying premium:");
    }
  } else {
    alert("Sum insured already reached");
  }
}

document
  .getElementById("premiumbutton")
  .addEventListener("click", async function () {
    const policyIdInput = document.getElementById("policyIdInput");

    const policyId = parseInt(policyIdInput.value);
    await window.ethereum.enable();
    await ethereum.send("eth_requestAccounts");
    await payPremium(policyId);
  });

// Event listener for the "Claim" button
document.getElementById("submit").addEventListener("click", async function () {
  const policyIdInput = document.getElementById("policyIdInput");
  const billIdInput = document.getElementById("billIdInput");

  const policyId = parseInt(policyIdInput.value);
  const billId = parseInt(billIdInput.value);

  const result = await contract.methods.policiesAvailable(policyId).call();
  const companyName = result.insuranceCompanyName;
  const policyName = result.policyName;
  const premiumtobepaid = result.premiumtobepaid;
  // const suminsuredbypolicy = result.suminsuredbypolicy;
  const billdetails = await contract.methods.billmapping(billId).call();
  const billamount = billdetails.amount;
  const premiumcount = JSON.parse(sessionStorage.getItem("premiumcount"));
  const premiumcount_policyindex = JSON.parse(
    sessionStorage.getItem("premiumcount_policyindex")
  );
  const indexs = premiumcount_policyindex.indexOf(policyId);
  console.log(premiumcount_policyindex);
  console.log(premiumcount);
  console.log(`Premium amount: ${premiumtobepaid}`);
  console.log(`premium count ${premiumcount[indexs]}`);
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
document
  .getElementById("claimButton")
  .addEventListener("click", async function () {
    const policyIdInput = document.getElementById("policyIdInput");
    const billIdInput = document.getElementById("billIdInput");

    const policyId = parseInt(policyIdInput.value);
    const billId = parseInt(billIdInput.value);

    await applyForClaim(policyId, billId);
  });

// Function to apply for claim
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
      // alert("premium amount not sufficient only Total premium will be paid");
      amountpaid = premiumpaidupuntilnow;
    }
    const result = await contract.methods
      .applyforclaim(accounts[0], policyId, billId)
      .send({ from: accounts[0], gas: "500000" });
    // console.log(result);
    console.log(
      "Claim applied successfully. Transaction:",
      result.transactionHash
    );
    const claimverification = await contract.methods
      .verifyCLaim(1, amountpaid)
      .send({ from: insaccounts[0], gas: "500000" });

    console.log(
      "Claim verified successfully. Transaction:",
      claimverification.transactionHash
    );
    // You can perform additional actions if needed

    const recAddress = accounts[0];
    const sendAddress = insaccounts[0];
    const sendPrivateKey = insPrivateKey;
    const recAddressBalanceBefore = await getAccountBalance(recAddress);
    const signedTx = await web3.eth.accounts.signTransaction(
      {
        from: sendAddress,
        to: recAddress,
        value: amountpaid,
        gas: 2000000,
      },
      sendPrivateKey
    );
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
