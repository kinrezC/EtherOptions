pragma solidity ^0.4.24;

import "openzeppelin-solidity/ownership/Ownable.sol";
import "openzeppelin-solidity/math/SafeMath.sol";

contract Proxy is Ownable {
    using SafeMath for uint;
}