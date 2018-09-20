pragma solidity ^0.4.24;

import "openzeppelin-solidity/math/SafeMath.sol";
import "./Proxy.sol";
import "./EOPT.sol";

contract EOPTFactor {
    using SafeMath for uint;

    address[] public _eoptContracts;
    address[] public _contractCreators;
    uint[] public _expirationBlocks;
    address private _proxyAddress;

    event LOG_NewContract (uint indexed expirationBlock, address indexed proxyAddr, uint contractNumber, address creator);

    constructor() {
        _proxyAddress = new Proxy();
    }

    function createContract(uint numBlockToExpiration) external {
        uint expirationBlock = uint(now) + numBlockToExpiration;

        for (uint32 i = 0; i < _expirationBlocks.length; i++) {
            require(expirationBlock != _expirationBlocks[i]);
        }

        uint contractNumber = _eoptContracts.length;
        _contractCreators.push(msg.sender);
        address newContract = new EOPT(expirationBlock, _proxyAddress, contractNumber, msg.sender);
        _eoptContracts.push(newContract);
        _expirationBlocks.push(expirationBlock);

        emit LOG_NewContract(expirationBlock, _proxyAddress, contractNumber, msg.sender);


    }

    function proxyAddress() public view returns (address) {
        return _proxyAddress;
    }

}