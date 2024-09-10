// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../interfaces/IFactory.sol";
import "../interfaces/IPair.sol";

library TokensUltility{
    function sortTokens(address _token1, address _token2) internal pure returns(address realToken1, address realToken2){
        (realToken1, realToken2) = _token1 > _token2 ? (_token2, _token1) : (_token1,_token2);
    }
    function sortAmounts(address _token1, address _token2, uint amount1, uint amount2) 
        internal pure returns(uint realAmount1, uint realAmount2){
        (realAmount1, realAmount2) = _token1 > _token2 ? (amount2, amount1) : (amount1, amount2);
    }
    function getAmountsIn(uint amountOut, address[] calldata path, address factory) internal view returns(uint){
        uint currentAmountOut = amountOut;
        for(uint i = path.length - 1; i > 0; i--){
            address pairAddress = IFactory(factory).getAddressOfPairs(path[i], path[i - 1]);
            uint reserve1 = IPair(pairAddress).reserve1();
            uint reserve2 = IPair(pairAddress).reserve2();
            if(path[i - 1] > path[i]){
                uint temp = reserve1;
                reserve1 = reserve2;
                reserve2 = temp;
            }
            currentAmountOut = (reserve1*currentAmountOut*1000)/((reserve2 - currentAmountOut)*997);
            require(currentAmountOut > 0, "POOL NOT HAVE ENOUGH");
        }
        return currentAmountOut;
    }
}
