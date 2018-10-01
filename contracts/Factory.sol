pragma solidity ^0.4.24;

import "./math/SafeMath.sol";
import "./Proxy.sol";
import "./EOPT.sol";

contract Factory {
    using SafeMath for uint;

    mapping (address => address) private _optionMinter;
    address[] private _eoptContracts;
    address private _proxy;
    Proxy proxy;

    event LOG_OPTIONCREATED (
    uint expirationBlock, 
    address optionAddr, 
    uint indexed contractNumber, 
    address indexed creator, 
    uint daiPrice
    );
    
    event LOG_PROXYCREATED (address indexed proxyAddr);

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

    function optionMinter(address optionAddr) public view returns (address) {
        return _optionMinter[optionAddr];
    }

    function createContract(uint numBlocks, uint daiPrice) external {
        require(numBlocks >= 1000);
        uint expirationBlock = uint(now) + numBlocks;
        uint contractNum = _eoptContracts.length;
        address newContract = new EOPT (
            "EtherOptions", 
            "EOPT", 
            18, 
            expirationBlock, 
            _proxy, 
            contractNum, 
            msg.sender, 
            daiPrice
        );
        proxy.newOptionIssuerInstance(newContract);
        _optionMinter[newContract] = msg.sender;
        _eoptContracts.push(newContract);

        emit LOG_OPTIONCREATED (
            expirationBlock, 
            newContract, 
            contractNum, 
            msg.sender, 
            daiPrice
        );
    }

}
 