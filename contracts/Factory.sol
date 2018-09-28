pragma solidity ^0.4.24;

import "./math/SafeMath.sol";
import "./Proxy.sol";
import "./EOPT.sol";

contract Factory {
    using SafeMath for uint;

    address[] private _eoptContracts;
    address private _proxy;
    uint private contractCount;
    Proxy proxy;

    event LOG_OPTIONCREATED(uint expirationBlock, address optionAddr, uint indexed contractNumber, address indexed creator, uint daiPrice);
    event LOG_PROXYCREATED(address indexed proxyAddr);

    constructor() public {
        _proxy = new Proxy(address(this));
        proxy = Proxy(_proxy);
       
        emit LOG_PROXYCREATED(_proxy);
    }

    function proxyAddress() public view returns (address) {
        return _proxy;
    }

    function eoptContracts(uint index) public view returns (address) {
        return _eoptContracts[index];
    }

    function createContract(uint numBlocks, uint daiPrice) external {
        require(numBlocks >= 1000);
        uint expirationBlock = uint(now) + numBlocks;
        contractCount += 1;
        address newContract = new EOPT("EtherOptions", "EOPT", 0, expirationBlock, _proxy, contractCount, msg.sender, daiPrice);
        proxy.newOptionInstance(newContract);

        _eoptContracts.push(newContract);

        emit LOG_OPTIONCREATED(expirationBlock, newContract, contractCount, msg.sender, daiPrice);
    }

}
 