// SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

// # Library / Dùng lib openzeppelin

// Ownable.sol còn có hàm đổi quyền, từ bỏ quyền owner, check ai là owner
contract UseOwnable is Ownable{
    uint public a = 0;
    function changeA() public onlyOwner {
        a++;
    }
}
