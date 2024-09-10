// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MyIERC165.sol";

// Ta k chơi kiểu abstract implement 1 interface và cho contract gốc kế thừa cái này như v, contract này có thể tái sử dụng ở nh contract khác r. Các hàm bên trong phải có virtual. 1 abstract contract k cần phải implement tất cả hàm của interface nó kế thừa
abstract contract MyERC165 is MyIERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(MyIERC165).interfaceId;
    }
    // Hàm type(X) sẽ lấy thông tin về loại biến X. Ta có thể lấy các thông tin như type(<contract>).name; trả ra tên contract
    // type(<interface>).interfaceId; trả ra interfaceId của interface truyền vào => học trong ERC-165
}