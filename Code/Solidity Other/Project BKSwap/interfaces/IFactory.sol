// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IFactory{
    function addrReceiveFee() external returns(address);
    function createPair(address _token1, address _token2) external returns(address);
    function getNumberOfPairs() external view returns(uint);
    function getAddressOfPairs(address _token1, address _token2) external view returns(address);
    
    event NewPair(address indexed addr);
}