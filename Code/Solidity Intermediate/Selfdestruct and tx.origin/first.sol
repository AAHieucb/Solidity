// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// # Basic / Dùng msg.sender và tx.origin

contract D {
    uint public x;
    constructor(uint a) payable {
        x = a;
    }
}

contract C {
    D d = new D(4); // Will be executed as part of C's constructor khi dùng k ở trong bất cứ 1 hàm nào nhưng điều đb là khai báo instance ở bên ngoài như thế này sẽ được tạo ngay lúc gọi constructor của contract
    // Nếu fix cứng thì dùng như này thay vì truyền vào constructor mất tg

    function createD(uint arg) public {
        D newD = new D(arg);
        newD.x(); // Hàm get ngầm tự đc tạo r. Có thể gọi hàm ez như này
        // Gọi x chứ hàm này k return, k return thì k xem được giá trị x đâu
    }
    
    function returnSender() public view returns (address) {
        return msg.sender;
    }
    function returnOrigin() public view returns (address) {
        return tx.origin;
    }
}

contract B {
    C a = C(address(0xDA0bab807633f07f013f94DD0E6A4F96F8742B53)); // Copy địa chỉ contract C vừa được deploy vào đây
    // Đây là TH 1 contract, ta có thể dùng contract C ở 1 file khác bằng cách deploy lấy address
    // Nch là 1 contract bình thường thì bản thân nó cũng dùng được như interface
    function returnSender() public view returns (address) {
        return a.returnSender();
    }
    function returnOrigin() public view returns (address) {
        return a.returnOrigin();
    }
    // Hàm tx.origin luôn trả ra đối tượng gốc tạo transaction. Còn msg.sender trả ra địa chỉ gần nhất gọi hàm
    // Ở đây: Account->gọi hàm contract B-> gọi hàm của A
    // msg.sender trả ra địa chỉ contract B, còn tx.origin trả ra account gốc
}
