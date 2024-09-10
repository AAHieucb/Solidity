pragma solidity >=0.7.0 <0.9.0;

// # Kế thừa class
// C kế thừa từ B và A
contract A {
    function foo() public virtual pure returns(string memory){
        // Chú ý có virtual ở class mẹ
        return "A";
    }
}

contract B {
    function foo() public virtual pure returns(string memory){
        return "B";
    }
}

contract C is B, A{
    function foo() public pure override(A, B) returns (string memory) {
        return super.foo(); // return giá trị của A vì A nằm bên phải sau từ khóa is
        // Nếu thích gọi hàm nào tùy ý thì tự dùng return B.foo(); chẳng hạn
    }
    // Khi kế thừa nhiều class, mà có hàm trùng trong nhiều class thì ta phải override tất cả các hàm trùng của các classes. Nó sẽ ưu tiên gọi hàm ta override trong class chính; nhưng nếu class chính lại gọi super để gọi các hàm trong class con thì nó sẽ tìm hàm đó trong các class theo thứ tự từ phải sang trái sau is thấy hàm trùng là dùng luôn
}
// Thứ tự contract sau is từ trái sang phải bắt buộc phải là từ more based-like sang more derived. Nếu k sẽ báo lỗi. VD: C kế thừa B và A. C is more derived than A và A is more based-like than C. Xong D kế thừa A và C thì phải dùng là contract D is A, C chứ k đc dùng contract D is C, A 
// Giả sử trong D gọi foo -> tìm trong D k có -> tìm kế thừa từ phải qua -> C gọi lại tìm từ phải qua -> gọi vào A vì A bên phải của B trong C, chơi cả lồng nhau như v
// Các contract cùng cấp, k more derived or more based-like thì tùy ý sắp xếp khi ta muốn thực hiện hàm của class nào trước
