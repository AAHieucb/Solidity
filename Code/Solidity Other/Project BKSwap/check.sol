pragma solidity >=0.7.0 <0.9.0;

import "./BKSwap/interfaces/IWETH.sol";

contract A{
    function getBalance(address addr) public view returns(uint){
        return address(addr).balance;
    }
    function check(address a, address b) public pure returns(bool){
        return a < b;
    }
}
contract B{
    address WETH;
    constructor(address _WETH) {
    }
    function test() public payable{
        IWETH(WETH).swapToWETH{value: msg.value}();
    }
    function test2(address addr, uint amount) public {
        IWETH(WETH).swaptoETH(amount);
        addr.call{value: amount}("");
    }
}

