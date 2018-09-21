const chai = require("chai");
const expect = chai.expect;
const chaiAsPromised = require("chai-as-promised");
chai.use(chaiAsPromised);

const Web3 = require("web3");
const web3Beta = new Web3(web3.currentProvider);
