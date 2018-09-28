var EOPT = artifacts.require("./EOPT.sol");
var factory = artifacts.require("./Factory.sol");
var Proxy = artifacts.require("./Proxy.sol");

var _factory;
var proxyAddr;

module.exports = function(deployer) {
  deployer.deploy(factory).then(async accounts => {
    _factory = await factory.deployed();
    proxyAddr = await _factory.proxyAddress();
  });
};
