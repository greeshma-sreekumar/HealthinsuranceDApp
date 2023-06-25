// const contractAddress = "0x9625dd057CAdFdB78E13731384813AC0Fe6E9A98";
// const abi = JSON.parse(sessionStorage.getItem("abi"));

const contractAddress = sessionStorage.getItem("contractAddress");

const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

const contract = new web3.eth.Contract(abi, contractAddress);

const account = sessionStorage.getItem("insaccount");

async function addNewPolicy(event) {
  event.preventDefault();

  try {
    const policyName = document.getElementById("policyName").value;
    const policyId = parseInt(document.getElementById("policyId").value);
    const ICregnum = parseInt(document.getElementById("ICregnum").value);
    const premiumToBePaid = parseInt(document.getElementById("premium").value);
    const sumInsuredByPolicy = parseInt(
      document.getElementById("sumInsured").value
    );

    const insuranceCompanyWalletAddress = account;
    await contract.methods
      .addnewpolicy(
        policyName,
        policyId,
        ICregnum,
        insuranceCompanyWalletAddress,
        premiumToBePaid,
        sumInsuredByPolicy
      )
      .send({ from: account, gas: "500000" });

    console.log("New policy added successfully!");
    alert("New policy added successfully!");

    const policyIdArray =
      JSON.parse(sessionStorage.getItem("policyIdArray")) || [];
    policyIdArray.push(policyId);
    sessionStorage.setItem("policyIdArray", JSON.stringify(policyIdArray));
  } catch (error) {
    console.error("Error adding new policy:", error);
    alert(error);
  }
}

// Attach event listener to the form submit event
const newPolicyForm = document.getElementById("newPolicyForm");
newPolicyForm.addEventListener("submit", addNewPolicy);
