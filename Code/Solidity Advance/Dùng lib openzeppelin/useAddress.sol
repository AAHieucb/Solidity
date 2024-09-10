// SPDX-License-Identifier:MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

// # Library / Dùng lib openzeppelin

// Thư viện address
contract BasicUtils {
    using Address for address;
    function checkIfContract(address _addr) public view returns(bool){
        return _addr.isContract();
    }

    using Address for address payable; // Phải có khi dùng với payable address
    uint private unlocked = 1;
    modifier blockReentrancy(){
        require(unlocked == 1, "LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    } 
    // Vì hàm sendValue của Address lib nguy hiểm vì k chống reentrancy
    function testSendValue(address payable recipient, uint256 amount) public blockReentrancy() {
        recipient.sendValue(amount);
    }
}