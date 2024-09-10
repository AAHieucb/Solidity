pragma solidity >=0.7.0 <0.9.0;

contract First{
    // # Basic / Block hay memory

    // Mặc định là private
    string public text = "Hello";

    // Khi khai báo string phải khai báo data location. Có 2 loại: nếu dùng storage thì dữ liệu phải được
    // lưu trong smart contract nằm trong block, nhưng string này được lấy từ bên ngoài người dùng nhập
    // vào và chỉ available khi function exec nên dùng memory. Hay nói cách khác mọi function input là public
    // đều phải dùng memory. Chỉ 1 số kiểu dữ liệu trong 1 số TH mới cần specific nơi lưu
    // biến bình thường khai báo ngoài hàm mặc định là storage rồi
    // VD: mapping, struct, array(string cx coi là array) mới cần specific data location trong 1 số TH
    function set(string memory _text) public { 
        text = _text;
    }
    // Tự tạo getter dù sol tự tạo getter r vì là biến public
    function get() public view returns (string memory){
        return text;
    }
}
