import { abi, contractAddress } from "./constants.js";

var Web3 = require("web3");
var web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));
if (!web3.isConnected()) {
  console.log("not connected");
}
var contract = web3.eth.contract(abi).at(contractAddress);
