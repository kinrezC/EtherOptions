pragma solidity ^0.4.24;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Mintable.sol";
import "openzeppelin-solidity/math/SafeMath.sol";
import "openzeppelin-solidity/ownership/Ownable.sol";

contract EOPT is ERC20, ERC20Detailed, ERC20Mintable {
    using SafeMath for uint;

    uint private _expirationBlock;
    address private _proxyAddr;
    uint private _contractNumber;
    address private _contractCreator;
    uint8 private _daiPrice;


    modifier onlyProxy() {
        require(address(0) != _proxyAddr);
        require(msg.sender == _proxyAddr);
        _;
    }

    modifier onlyIfExpired() {
        require(now >= _expirationBlock);
        _;
    }

    function() public payable {
        
    }


    constructor( 
    uint expirationBlock, 
    address proxyAddr, 
    uint contractNumber,
    address contractCreator,
    uint8 daiPrice
    )
    ERC20Mintable() 
    ERC20Detailed("EtherOptions", "EOPT", 0) 
    ERC20() {
        addMinter(proxyAddr);
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

    function daiPrice() public view returns (uint8) {
        return _daiPrice;
    }

    function assertMintingFinished() onlyIfExpired public returns (bool) {
        require(now >= _expirationBlock);
        finishMinting();
    }

    function mintOption(address owner, uint amount) public onlyProxy {
        _mint(owner, amount);
    }


    
}