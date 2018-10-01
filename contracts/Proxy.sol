pragma solidity ^0.4.24;

import "./math/SafeMath.sol";
import "./erc20/ERC20.sol";
import "./erc20/ERC20Detailed.sol";
import "./EOPT.sol";

contract Proxy  {
    using SafeMath for uint;

    mapping (address => bool) private _isOptionsContract;
    mapping (address => bool) private _isMinter;
    mapping (address => uint) private _balances;
    mapping (uint => address) private _contractNumber;

    uint private _optionsMinted;
    uint private _totalSupply;
    address private _factoryContract;

    event LOG_OPTION (address indexed optionAddr, uint indexed optionNumber);

    modifier onlyFactory() {
        require(msg.sender == _factoryContract);
        _;
    }

    constructor(address factory) public {
        _factoryContract = factory;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function factoryContract() public view returns (address) {
        return _factoryContract;
    }

    function getBalance(address addr) public view returns (uint) {
        return _balances[addr];
    }
    
    function optionsMinted() public view returns (uint) {
        return _optionsMinted;
    }

    function() external payable {
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

    function newOptionIssuerInstance(address optionAddr) external onlyFactory {
        _optionsMinted += 1;
        _contractNumber[_optionsMinted] = optionAddr;
        _isOptionsContract[optionAddr] = true;

        emit LOG_OPTION(optionAddr, _optionsMinted);
    }

    function assertIsMinter(address optionAddr) internal {
        require(_isOptionsContract[optionAddr]);
        EOPT eopt = EOPT(optionAddr);
        eopt.assertMinter();
        _isMinter[optionAddr] = true;
    }

    function mintOption(address optionAddr, uint amount) external {
        require(_balances[msg.sender] >= amount * 10**18);
        require(_isOptionsContract[optionAddr] == true);
        EOPT eopt = EOPT(optionAddr);
        if (_isMinter[optionAddr]) {
            eopt.mintOption(msg.sender, amount);
        }
        else {
            assertIsMinter(optionAddr);
        }
    }

}