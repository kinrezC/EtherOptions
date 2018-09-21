pragma solidity ^0.4.24;

import "openzeppelin-solidity/math/SafeMath.sol";
import "./Proxy.sol";
import "./EOPT.sol";

contract EOPTFactor {
    using SafeMath for uint;

    address[] public _eoptContracts;
    address[] public _contractCreators;
    uint[] public _expirationBlocks;
    address private _proxy;
    Proxy proxy;

    event LOG_NewContract (uint indexed expirationBlock, address proxy, uint contractNumber, address creator, uint8 indexed daiPrice);

    constructor() {
        _proxy = new Proxy(address(this));
        proxy = Proxy(_proxy);
    }

    function proxyAddress() public view returns (address) {
        return _proxy;
    }

    function createContract(uint numBlockToExpiration, uint8 daiPrice) external {
        require(numBlockToExpiration >= 1000);
        uint expirationBlock = uint(now) + numBlockToExpiration;
        
        for (uint32 i = 0; i < _expirationBlocks.length; i++) {
            require(expirationBlock != _expirationBlocks[i]);
        }

        uint contractNumber = _eoptContracts.length;
        _contractCreators.push(msg.sender);
        address newContract = new EOPT(expirationBlock, _proxy, contractNumber, msg.sender, daiPrice);
        proxy.newOptionInstance(newContract);
        _eoptContracts.push(newContract);
        _expirationBlocks.push(expirationBlock);

        emit LOG_NewContract(expirationBlock, _proxy, contractNumber, msg.sender, daiPrice);


    }

}