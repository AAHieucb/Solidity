pragma solidity ^0.8.0;

// # Các EIP khác / EIP165

contract B{
    // mapping(bytes4 => bool) private _interface;
    // 1 cách khác thay vì làm kiểu này là nó gán _interfaceId[this.foo.selector] = bằng true ở hàm khởi tạo và supportsInterface
    // Chỉ check _interfaceId[interfaceId truyền vào] bằng true hay false thôi, true là có hỗ trợ hàm đó. Chuẩn này xàm vì ta biết code contract thì biết luôn nó có support hàm hay không rồi, cần gì phải gọi hàm này để check
    function supportsInterface(bytes4 interfaceId) external pure returns(bool){
        return interfaceId == this.foo.selector || interfaceId == this.bar.selector;
    }
    function foo() external pure returns(uint) {
        return 1;
    }
    function bar() external pure returns(uint) {
        return 1;
    }
}

// Tình huống: VD contract A muốn gọi 1 hàm foo của contrat B nhưng lại k rõ contract B có hàm foo hay k. Người ta dùng 1 cách đó là để contract B publish interface or function nào mà nó biểu diễn, gói trong 1 hàm => người nào code contract A muốn check xem contract B có hàm nào k thì gọi hàm supportsInterface và truyền vào selector của hàm đó. Ta check như trên:
contract A{
    B b = new B();
    function callFoo() public view returns(uint){
        if(b.supportsInterface(b.foo.selector))
            return b.foo();
        else 
            return 0;
    }
}
// Hàm this.foo.selector thực chất là: bytes4(keccak256("foo()")); => nó tương đương như v, tức là mã hóa signature của hàm và lấy ra 4 bytes đầu tiên nên vẫn có thể trùng

// Cách bên trên là check 2 hàm foo và bar có được implements ở trong contract đó hay k. Trong thực tế, các contract sẽ k check như v mà check theo interface. interfaceId của 1 interface sẽ check xem 1 contract có dùng interface nào hay k. Khi 1 contract có interfaceId của interface đó thì nó phải gọi hết các hàm trong interface đó, thế là ta bt được 1 contract gọi những hàm nào
interface TestInterfaceId{
    function function1() external pure;
    function function2() external pure;
}
contract B1 is TestInterfaceId{
    function supportsInterface() public pure returns(bytes4){
        return type(TestInterfaceId).interfaceId;
    }
    function function1() public override pure{}
    function function2() public override pure{}
}
// Hàm type(<interface>).interfaceId trả ra interfaceId của 1 interface. 
// InterfaceId hình thành bằng: bytes4(keccak256("function1()")) ^ bytes4(keccak256("function2()")); đối với mọi hàm trong interface => điều này tương đương với function1.selector ^ function2.selector -> nếu thêm hàm vào interface thì interfaceId sẽ thay đổi. Phép ^ chính là phép XOR, tức chỉ 1 XOR 0 = 1 => ta có thể tự tính được interfaceId của bất cứ contract nào ta tạo ra
// Trong thực tế, người ta sẽ tạo ra interface cho contract trước và khi tạo hàm supportsInterface sẽ check mọi interface mà contract này implements và các hàm rời ra nếu có


// Người ta định nghĩa ra chuẩn EIP-165 là chuẩn xác định interfaceId. 1 contract tuân theo chuẩn này sẽ: có 1 hàm tên là supportsInterface check tất cả các interface mà nó dùng cho contract này. Và để báo hiệu 1 contract dùng EIP-165, người ta sẽ cho kế thừa IERC165 của openzepplin. Mô hình như dưới: contract tuân theo EIP-165 và check mọi interface
interface MyIERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract MyERC165 is MyIERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(MyIERC165).interfaceId;
    }
}
interface InterfaceForContract{
    function function1() external pure; 
}
contract MyContract is MyERC165, InterfaceForContract{
    function function1() public override pure {}
    function supportsInterface(bytes4 interfaceId) public view override returns(bool){
        return interfaceId == type(MyERC165).interfaceId ||
            interfaceId == type(InterfaceForContract).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
// Đây là mô hình 1 contract bình thường có thêm chuẩn ERC165
// interface của ERC-165 mặc định là 0x01ffc9a7, nếu ta dùng bytes4(keccak256('supportsInterface(bytes4)')) or selector cũng cho kết quả như v. Bởi vì IERC165 chỉ có mỗi hàm dó thôi. Mà selector tính bằng signature của function nên các contract có cùng function or function content khác mà signature như nhau thì vẫn cùng selector
// => Có thể gọi hàm với 0x01ffc9a7 để check 1 contract có dùng chuẩn 165 hay k => vì công khai nên chuẩn này éo có gì qtr

// Ta cx có thể check interface mà k dùng hàm type() bằng cách tính chay như cách đầu tiên, ở constructor: 
// _interfaceId[<bytes4 keccak256 signature từng hàm cách nhau bằng ^>] = true;
