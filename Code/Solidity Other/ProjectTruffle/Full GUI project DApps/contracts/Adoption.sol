// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 <0.9.0;

// Dấu ^ là >=0.5.0 đó nhưng ^ nh lúc k đc chấp nhận. Chú ý đặt giống như file migration
// Ở đây phải là <0.9.0 mới chạy

contract Adoption {
    address[16] public adopters;
    function adopt(uint petId) public returns (uint) {
        require(petId >= 0 && petId <= 15); 
        adopters[petId] = msg.sender; 
        return petId;
    }
    function getAdopters() public view returns (address[16] memory) { 
        return adopters;
    }
    // Hàm này cần thiết vì hàm get mặc định chỉ trả ra 1 giá trị theo index nhưng ta cần hiển thị tất cả mảng để biết tình trạng thú cưng là vô chủ hay có chủ, k thể gọi 16 API đc nên dùng 1 hàm get. Do mảng ít phần từ và fix số lượng phần tử nên lấy kiểu này được
}