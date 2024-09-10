// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Abstract contract cx như interface v. Muốn dùng nó đều phải kế thừa is cả hai. Nên nhớ abstract contract nó như gắn liền vào contract thực v, như là 1 contract tái sử dụng nên các hàm ta dùng là internal + virtual, còn interface các hàm là external.
// Abstract contract thì có thể tái sử dụng ở nh nơi và đã implement r còn interface thì k
// Dùng khi kiểu thêm tính năng cho contract 1 vài hàm
abstract contract MyContext{
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
