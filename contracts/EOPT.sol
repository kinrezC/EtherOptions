pragma solidity ^0.4.24;

import "./erc20/ERC20.sol";
import "./erc20/ERC20Detailed.sol";
import "./erc20/ERC20Mintable.sol";

contract EOPT is ERC20, ERC20Detailed, ERC20Mintable {

    uint private _expirationBlock;
    address private _proxyAddr;
    uint private _contractNumber;
    address private _contractCreator;
    uint private _daiPrice;
    bool private _isExpired;


    modifier onlyProxy() {
        require(address(0) != _proxyAddr);
        require(msg.sender == _proxyAddr);
        _;
    }

    modifier onlyIfExpired() {
        require(now >= _expirationBlock);
        _;
    }

    modifier onlyIfNotExpired() {
        require(now < _expirationBlock);
        _;
    }

    constructor( 
    string name,
    string symbol,
    uint8 decimals,
    uint expirationBlock, 
    address proxyAddr, 
    uint contractNumber,
    address contractCreator,
    uint daiPrice
    )
    ERC20Mintable() 
    ERC20Detailed(name, symbol, decimals) 
    ERC20() public {
        _expirationBlock = expirationBlock;
        _proxyAddr = proxyAddr;
        _contractNumber = contractNumber;
        _contractCreator = contractCreator;
        _daiPrice = daiPrice;
    }

    function contractNumber() public view returns (uint) {
        return _contractNumber;
    }

    function expirationBlock() public view returns (uint) {
        return _expirationBlock;
    }

    function contractCreator() public view returns (address) {
        return _contractCreator;
    }

    function daiPrice() public view returns (uint) {
        return _daiPrice;
    }

    function isExpired() public view returns (bool) {
        return _isExpired;
    }

    function assertMintingFinished() onlyIfExpired public returns (bool) {
        require(now >= _expirationBlock);
        finishMinting();
    }

    function mintOption(address owner, uint amount) public onlyProxy {
        if (now >= _expirationBlock) {
            _isExpired = true;
        }
        else {
            if (isMinter(_proxyAddr) == false) {
                addMinter(_proxyAddr);  
                _mint(owner, amount);        
            }
            else {
                _mint(owner, amount);
            }
        }
    }


    
}