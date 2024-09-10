// SPDX-License-Identifier: MIT
// Dòng trên có tác dụng thêm giấy phép bỏ warning
pragma solidity >=0.7.0 <0.9.0;

interface Test{ // Trong interface k có biến
    function test(uint _x) external view returns(uint);
}

contract Test1 is Test{
    function test(uint _x) public override pure returns(uint){
        return _x;
    }
    uint public constant a = 10; // Function constant đã deprecated, đc thế bởi pure/view. Biến constant cx chả dùng nx
    
    string private name;
    function getName() public view returns(string memory){
        return name;
    } // Họ có xu hướng tạo ra các biến private, nhưng vẫn muốn lấy giá trị ra xem -> tự tạo get
}
// Khi 1 contract kế thừa từ 1 interface thì contract phải khai báo tất cả hàm của interface đó. Các hàm phải có thêm (virtual) override ở trong contract và trong interface phải dùng external
// Ở ví dụ trên trong interface ta dùng view, nhưng trong contract dùng pure cx đc, do trong interface k có implement nên như v, cứ làm miễn thỏa mãn là đc. View và pure ở interface và contract có thể k giống nhau
