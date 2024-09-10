// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./interfaces/IFactory.sol";
import "./interfaces/IPair.sol";
import "./otherlibs/SafeMath.sol";
import "./otherlibs/Math.sol";

contract OraclBKSwap{
    address factory;
    address WETH; 
    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }
    function getAmountOfETH(address token, uint amount) public view returns(uint){
        address pairAddress = IFactory(factory).getAddressOfPairs(token, WETH);
        require(pairAddress != address(0), "PAIR NOT EXIST");
        uint amount1 = IPair(pairAddress).reserve1();
        uint amount2 = IPair(pairAddress).reserve2();
        require(amount1 > 0 && amount2 > 0, "PAIR EMPTY");
        (amount1, amount2) = token < WETH ? (amount1, amount2) : (amount2, amount1);
        // Cách hoán vị 2 biến trong solidity mà k cần temp
        return Math.mulDiv(amount, amount2, amount1);
    }
}