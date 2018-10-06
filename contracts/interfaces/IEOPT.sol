pragma solidity ^0.4.24;

interface IEOPT {
    function mintOption(address owner, uint amount) external;
    function assertMinter() external;
}