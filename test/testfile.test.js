const Factory = artifacts.require("./Factory.sol");
const Proxy = artifacts.require("./Proxy.sol");
const EOPT = artifacts.require("./EOPT.sol");

var factoryContract;
var proxyContract;
var eoptContract;

contract("Factory, Proxy, EOPT", accounts => {
  it("Factory Contract: Creates a proxy contract", async () => {
    factoryContract = await Factory.new();
    let _proxy = await factoryContract.proxyAddress();
    proxyContract = await Proxy.at(_proxy);
    let savedAddr = await proxyContract.factoryContract();
    assert.equal(savedAddr, factoryContract.address);
  });

  it("Factory Contract: Can mint new options contracts", async () => {
    await factoryContract.createContract(10000, 500);
    let eopt = await factoryContract.eoptContracts(0);
    eoptContract = await EOPT.at(eopt);
    assert.equal(eoptContract.address, eopt);
  });

  it("Factory Contract: Can correctly fetch option minter address", async () => {
    let optionMinter = await factoryContract.optionMinter(eoptContract.address);
    assert.equal(optionMinter, accounts[0]);
  });

  it("Factory Contract: Can correctly fetch option contract at index 0", async () => {
    let optionAddress = await factoryContract.eoptContracts(0);
    assert.equal(optionAddress, eoptContract.address);
  });

  it("Proxy contract: Should successfully fetch factory contract address", async () => {
    let factoryAddress = await proxyContract.factoryContract();
    assert.equal(factoryContract.address, factoryAddress);
  });

  it("Proxy contract: Accepts ether and adjusts balances accordingly", async () => {
    let acct1StartBalance = web3.eth.getBalance(accounts[0]);
    await proxyContract.deposit({
      from: accounts[0],
      value: web3.toWei(1, "ether"),
      gasPrice: 0
    });
    let balance = await proxyContract.getBalance(accounts[0]);
    let balanceInEther = web3.fromWei(balance, "ether").toNumber();
    let acct1EndBalance = web3.eth.getBalance(accounts[0]);
    let deltaInWei = acct1StartBalance - acct1EndBalance;
    let delta = web3.fromWei(deltaInWei, "ether");
    assert.equal(delta, balanceInEther);
  });

  it("Proxy contract: Minting increases total supply accordingly", async () => {
    let totalSupply = await proxyContract.totalSupply();
    let totalSupplyInEth = web3.fromWei(totalSupply, "ether");
    assert.equal(totalSupplyInEth, 1);
  });

  it("Proxy contract: Allows users to withdraw their funds", async () => {
    let acct1BalanceStart = web3.eth.getBalance(accounts[0]);
    let acct1BalanceInEthStart = web3
      .fromWei(acct1BalanceStart, "ether")
      .toNumber();
    let contractBalanceStart = await proxyContract.getBalance(accounts[0]);
    let wethBalanceStart = web3
      .fromWei(contractBalanceStart, "ether")
      .toNumber();
    await proxyContract.withdraw(web3.toWei(1, "ether"), {
      from: accounts[0],
      gasPrice: 0
    });
    let acct1BalanceEnd = web3.eth.getBalance(accounts[0]);
    let acct1BalanceInEthEnd = web3
      .fromWei(acct1BalanceEnd, "ether")
      .toNumber();
    let contractBalanceEnd = await proxyContract.getBalance(accounts[0]);
    let wethBalanceEnd = web3.fromWei(contractBalanceEnd, "ether").toNumber();
    assert.equal(wethBalanceEnd + 1, wethBalanceStart);
    assert.equal(acct1BalanceInEthStart + 1, acct1BalanceInEthEnd);
  });

  it("Proxy contract: Fallback function works correctly", async () => {
    let etherBalanceStart;
    let etherBalanceEnd;
    let wethBalanceEnd;
    let wetherBalanceEnd;
    let ethBalanceStart;
    let ethBalanceEnd;

    etherBalanceStart = web3.eth.getBalance(accounts[0]);
    ethBalanceStart = web3.fromWei(etherBalanceStart, "ether").toNumber();
    await web3.eth.sendTransaction({
      from: accounts[0],
      to: proxyContract.address,
      value: web3.toWei(1, "ether"),
      gasPrice: 0
    });
    etherBalanceEnd = web3.eth.getBalance(accounts[0]);
    ethBalanceEnd = web3.fromWei(etherBalanceEnd, "ether").toNumber();
    wetherBalanceEnd = await proxyContract.getBalance(accounts[0]);
    wethBalanceEnd = web3.fromWei(wetherBalanceEnd, "ether").toNumber();

    assert.equal(wethBalanceEnd, 1);
    assert.equal(ethBalanceStart - 1, ethBalanceEnd);
  });

  it("EOPT Contract: Stores the correct dai price", async () => {
    let expectedPrice = 500;
    let daiPrice = await eoptContract.daiPrice();
    assert.equal(daiPrice, expectedPrice);
  });

  it("EOPT Contract: Fetches the correct contract creator address", async () => {
    let expectedAddress = accounts[0];
    let storedAddress = await eoptContract.contractCreator();
    console.log(expectedAddress);
    assert.equal(expectedAddress, storedAddress);
  });

  it("EOPT Contract: Mints new options when called by proxy contract", async () => {
    let balance = await proxyContract.getBalance(accounts[0]);
    let balanceInEther = web3.fromWei(balance, "ether").toNumber();
    console.log("Current balance: ", balanceInEther);
    await proxyContract.mintOption(eoptContract.address, 1, {
      from: accounts[0],
      gasPrice: 0
    });
    let eoptBalance = await eoptContract.getBalance(accounts[0]);
    let eoptBalanceInEther = web3.fromWei(eoptBalance, "ether").toNumber();
    console.log("Ether options owned: ", eoptBalanceInEther);
  });
});
