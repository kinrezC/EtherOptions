var EOPT = artifacts.require("./EOPT.sol");
var EOPTFactory = artifacts.require("EOPTFactory.sol");
var Proxy = artifacts.require("./Proxy.sol");

var factoryAddr;
let deployedContractAddress = [];

contract("EOPTFactory", async accounts => {
  it("Should deploy proxy contract instance"),
    async () => {
      let instance = await EOPTFactory.deployed();
      factoryAddr = instance.address;
    };
});
