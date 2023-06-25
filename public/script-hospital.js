// const contractAddress = "0xcD1b16f532d7598DF554ed7d088179c6d5c7d84e";
// const abi = JSON.parse(sessionStorage.getItem("abi"));

const contractAddress = sessionStorage.getItem("contractAddress");

const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

const contract = new web3.eth.Contract(abi, contractAddress);

// const account = document.getElementById("walletaddress").value;
const account = sessionStorage.getItem("hopaccount");

document
  .getElementById("generateBillButton")
  .addEventListener("click", generateBillForPatient);

// Get the form elements
// const patientAddressInput = document.getElementById("patientAddressInput");
const diseaseCodeInput = document.getElementById("disease-code");
const descriptionInput = document.getElementById("descriptionInput");
const roomChargesInput = document.getElementById("roomcharges");
const medicationInput = document.getElementById("medication");
const laboratoryInput = document.getElementById("laboratory");
const surgeriesInput = document.getElementById("surgeries");
const therapiesNconsultationsInput = document.getElementById(
  "therapiesNconsultations"
);
const anyotherchargesInput = document.getElementById("anyothercharges");
const discountInput = document.getElementById("discount");
const amountInput = document.getElementById("amountInput");

async function generateBillForPatient() {
  const patientAddresss = await web3.eth.getAccounts();
  const patientAddress = patientAddresss[0];
  // const patientAddress = document.getElementById("patientAddressInput").value;
  const description = document.getElementById("descriptionInput").value;

  try {
    const roomCharges = parseFloat(roomChargesInput.value);
    const medication = parseFloat(medicationInput.value);
    const laboratory = parseFloat(laboratoryInput.value);
    const surgeries = parseFloat(surgeriesInput.value);
    const therapiesNconsultations = parseFloat(
      therapiesNconsultationsInput.value
    );
    const anyothercharges = parseFloat(anyotherchargesInput.value);
    const discount = parseFloat(discountInput.value);
    const totalAmount =
      roomCharges +
      medication +
      laboratory +
      surgeries +
      therapiesNconsultations +
      anyothercharges -
      discount;
    amountInput.textContent = "Total Bill Amount: " + totalAmount;
    const result = await contract.methods
      .generatebBillforpatient(patientAddress, totalAmount, description)
      .send({ from: account, gas: "500000" });
    console.log(result);
    console.log(
      "Bill generated successfully. Transaction:",
      result.transactionHash
    );
    const customerData = await contract.methods
      .customerData(patientAddress)
      .call();
    const billId = customerData.billId;
    console.log(billId);
    alert(`Bill generated successfully. BillID: ${billId}`);

    // You can perform additional actions if needed
  } catch (error) {
    console.error("Error generating bill:", error);
  }
}
