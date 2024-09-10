// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IPair{
    function reserve1() external view returns(uint);
    function reserve2() external view returns(uint);
    function mintFeeForDev() external;
    function addLiquidity(address to) external returns(uint);
    function removeLiquidity(address to) external returns(uint, uint);
    function swap(address to, uint amount1, uint amount2) external returns(uint);
    function skim(address to) external;
    function sync() external;
}