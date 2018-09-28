pragma solidity ^0.4.24;

interface IProxy {
    function newOptionInstance(address optionAddr) external;
}