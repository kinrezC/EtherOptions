const Factory = artifacts.require("./Factory.sol");
const Proxy = artifacts.require("./Proxy.sol");
const EOPT = artifacts.require("./EOPT.sol");

var factoryContract;
var proxyContract;
var eoptContract;

contract("Factory", accounts => {
  it("Creates a proxy contract", async () => {
    factoryContract = await Factory.new();
    let _proxy = await factoryContract.proxyAddress();
    proxyContract = await Proxy.at(_proxy);
    let savedAddr = await proxyContract.factoryContract();

    assert.equal(savedAddr, factoryContract.address);
  });

  it("Can mint new options contracts", async () => {
    await factoryContract.createContract(10000, 500);
    let eopt = await factoryContract.eoptContracts(0);
    eoptContract = await EOPT.at(eopt);
    assert.equal(eoptContract.address, eopt);
  });

  it("Can correctly fetch option minter address", async () => {
    let optionMinter = await factoryContract.optionMinter(eoptContract.address);
    assert.equal(optionMinter, accounts[0]);
  });

  it("Can correctly fetch option contract at index 0", async () => {
    let optionAddress = await factoryContract.eoptContracts(0);
    assert.equal(optionAddress, eoptContract.address);
  });
});
