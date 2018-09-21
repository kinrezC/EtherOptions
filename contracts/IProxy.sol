pragma solidity ^0.4.21;

interface IProxy {
    function newOptionInstance(address optionAddr) external;
}