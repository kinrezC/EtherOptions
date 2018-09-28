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
    console.log("eopt address: ", eopt);
    eoptContract = await EOPT.at(eopt);
    assert.equal(eoptContract.address, eopt);
  });
});
