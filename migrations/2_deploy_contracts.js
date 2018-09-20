var EOPT = artifacts.require("./EOPT.sol");
var EOPTFactory = artifacts.require("EOPTFactory.sol");
var Proxy = artifacts.require("./Proxy.sol");

module.exports = function(deployer) {
  deployer.deploy(EOPTFactory.sol).then(async accounts => {
    var factory = EOPTFactory.deployed();
    var proxyAddr = await factory.proxyAddress();
  });
};
