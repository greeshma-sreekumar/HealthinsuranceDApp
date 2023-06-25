const express = require("express");
const app = new express();
const path = require("path");
app.use(express.static("public"));
app.get("/", (req, res) => {
  res.sendFile(__dirname + "/home.html");
});
app.get("/hospital", (req, res) => {
  res.sendFile(__dirname + "/hospital.html");
});
app.get("/customer", (req, res) => {
  res.sendFile(__dirname + "/customer.html");
});
app.get("/insuCompany", (req, res) => {
  res.sendFile(__dirname + "/insuCompany.html");
});
app.listen(3001, () => console.log("server is listening..."));

// var Web3 = require("web3");

// const provider = new Web3.providers.HttpProvider("http://localhost:8545");
// const web3 = new Web3(provider);
const Web3 = require("web3");
const ganache = require("ganache");

const web3 = new Web3(ganache.provider());
