// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IRouter{
    function addLiquidity(address token1, address token2, uint amount1, uint amount2, address to, uint deadline) 
    external;
    function addLiquidityWithETH(address token, uint amount, address to, uint deadline) external payable;
    function removeLiquidity(address token1, address token2, uint minAmount1, uint minAmount2, uint amount, address to,
    uint deadline) external;
    function removeLiquidityWithETH(address token, uint minAmount, uint minAmountETH, uint amount, address to,
    uint deadline) external;
    function removeLiquidityWithPermit(address token1, address token2, uint minAmount1, uint minAmount2, uint amount, 
    address to, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function removeLiquidityETHWithPermit(address token, uint amount, uint minAmountToken, uint minAmountETH, 
    address to, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function removeLiquiditySupportFeeOnTransferToken(address token1, address token2, uint minAmount1, uint minAmount2, uint amount, 
    address to, uint deadline) external;
    function removeLiquidityWithPermitSupportFeeOnTransferToken(address token1, address token2, uint minAmount1, uint minAmount2, 
    uint amount, address to, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function removeLiquidityETHSupportFeeOnTransferToken(address token, uint minAmount, uint minAmountETH, uint amount, address to,
    uint deadline) external;
    function removeLiquidityETHWithPermitSupportFeeOnTransferToken(address token, uint amount, uint minAmountToken, uint minAmountETH, 
    address to, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function swapExactTokenForToken(uint amount, address to, uint minAmount2, address[] calldata path, uint deadline)
    external;
    function swapExactTokenForETH(uint amount, address to, uint minAmountETH, address[] calldata path, uint deadline) 
    external;
    function swapExactETHForToken(address to, uint minAmountToken, address[] calldata path, uint deadline) 
    payable external returns(uint);
    function swapTokenForExactToken(uint amountInMax, uint amountOut, address to, address[] calldata path, 
    uint deadline) external;
    function swapTokenForExactETH(uint amountInMax, uint amountOut, address to, address[] calldata path, uint deadline)
    external;
    function swapETHForExactToken(uint amountOut, address to, address[] calldata path, uint deadline) 
    external payable;
    function swapExactTokenForTokenSupportFeeOnTransferToken(uint amount, address to, uint minAmount2, address[] calldata path, 
    uint deadline) external;
    function swapExactTokenForETHSupportFeeOnTransferToken(uint amount, address to, uint minAmountETH, address[] calldata path, uint deadline) 
    external;
    function swapExactETHForTokenSupportFeeOnTransferToken(address to, uint minAmountToken, address[] calldata path, uint deadline) 
    payable external;
}
