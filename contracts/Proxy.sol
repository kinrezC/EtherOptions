pragma solidity ^0.4.24;

import "./math/SafeMath.sol";
import "./erc20/ERC20.sol";
import "./erc20/ERC20Detailed.sol";
import "./EOPT.sol";

contract Proxy is ERC20, ERC20Detailed {
    using SafeMath for uint;

    mapping (address => bool) private _isOptionsContract;
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

    constructor(address factory) 
    ERC20() 
    ERC20Detailed(
        "Wrapped Ether", 
        "WETH", 
        18
    ) 
    public {
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

    function newOptionIssuerInstance(address optionAddr) external onlyFactory {
        _optionsMinted += 1;
        _contractNumber[_optionsMinted] = optionAddr;

        emit LOG_OPTION(optionAddr, _optionsMinted);
    }

    function mintOption(address optionAddr, uint amount) external {
        require(_balances[msg.sender] >= amount * 10**18);
        require(_isOptionsContract[optionAddr] == true);
        EOPT eopt = EOPT(optionAddr);
        bool isExpired = eopt.isExpired();
        require(isExpired == false);
        eopt.mintOption(msg.sender, amount);

    }

}