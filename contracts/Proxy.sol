pragma solidity ^0.4.24;

import "openzeppelin-solidity/ownership/Ownable.sol";
import "openzeppelin-solidity/math/SafeMath.sol";

contract Proxy is Ownable {
    using SafeMath for uint;

    address[] private optionTypes;
    mapping (address => bool) private _isNotExpired;
    mapping (address => bool) private _isOptionsContract;
    mapping (address => uint) private _balances;
    uint private _totalSupply;
    address private _factoryContract;

    constructor(address factoryContract) {
        _factoryContract = factoryContract;
    }

    modifier isNotExpired() {
        require(_isNotExpired[msg.sender] == true);
        _;
    }

    modifier onlyFactory() {
        require(msg.sender == _factoryContract);
        _;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function factoryContract() public view returns (address) {
        return _factoryContract;
    }

    function() public payable {
        deposit();
    }

    function deposit() public payable {
        _balances[msg.sender] += msg.value;
        _totalSupply += msg.value;
    }

    function withdraw(uint amount) public {
        require(_balances[msg.sender] >= amount);
        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        address(msg.sender).transfer(amount);
    }

    function newOptionInstance(address optionAddr) external onlyFactory {

    }

}