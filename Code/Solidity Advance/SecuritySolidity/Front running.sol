// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// # Bảo mật Sol / Front running

// Giả sử contract này hoạt động kiểu: ai tìm ra 1 chuỗi string có bnh ký tự mà hash được ra cái mã hash kia sớm nhất sẽ nhận được 10ether do contract này gửi đến
// Alice tìm được string thỏa mãn -> gửi trans để gọi solve và nhận thưởng -> contract của alice ở trong mempool -> Bob thấy contract của Alice đúng liền copy nó và set higher gas fee và gửi đi -> cả contract của Bob và Alice đều ở trong mempool nhưng contract của Bob được thực hiện trước vì higher gas fee -> Bob nhận được thưởng còn Alice đến sau nên k được. Gọi là front-running.
contract FindThisHash {
    bytes32 public constant hash =
        0x564ccaf7594d66b1eaaea24fe01f0585bf52ee70852af4eac0cc4b04711cd0e2;

    constructor() payable {}

    function solve(string memory solution) public {
        require(hash == keccak256(abi.encodePacked(solution)), "Incorrect answer");

        // Ở đây giả sử contract này có 10ether nên chỉ 1 người được nhận thưởng
        (bool sent, ) = msg.sender.call{value: 10 ether}("");
        require(sent, "Failed to send Ether");
    }
}
// Kinh nghiệm: khi tạo contract thì phải tính tránh được lỗi có ai đó sẽ copy trans đó và thay đổi thứ tự execute 