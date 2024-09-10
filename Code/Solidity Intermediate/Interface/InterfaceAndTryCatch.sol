pragma solidity ^0.8.0;

// # Dùng interface

// Interface có các cách dùng cho đến h: để gọi hàm của 1 contract khác trong 1 contract này -> gọi thông qua interface (đã biết); Dùng kiểu 1 contract kế thừa 1 interface để báo hiệu contract này implement cái interface nào, nhờ đó các nơi khác có thể dùng các hàm getter từ contract của ta để lấy thông tin.
// VD: gọi hàm contract khác
contract Original{
    function add(uint a, uint b) public pure returns(uint){
        return a + b;
    }
}

// Bh contract A và B muốn dùng hàm pure add của contract original => k cần viết lại logic có sẵn
interface addContract{
    function add(uint a, uint b) external pure returns(uint);
}
contract A{
    function useAdd(address address_) public pure returns(uint){
        return addContract(address_).add(1, 2);
    }
}

// TH trên là ta gọi 1 contract ở xa thông qua address của contract. Với các contract ở cùng file, ta có thể tạo mới nó vói new r gọi
// Ta phải cho kế thừa mới đc vì cái contract cần convert được sang interface đó nên là 1 instance của interface đó
interface addContract2{
    function add(uint a, uint b) external pure returns(uint);
}
contract Original2 is addContract2{
    function add(uint a, uint b) public pure override returns(uint){ // Khi kế thừa lại hàm phải dùng override
        return a + b;
    }
}
contract B{ // Chỉ cần deploy contract B k cần deploy contract Original2
    addContract2 obj;
    function useAdd() public returns(uint){
        obj = new Original2();
        // Có thể éo dùng new mà dùng 1 địa chỉ có sẵn r với = Original2(address(<address>)); Tương tự gọi từ interface
        return obj.add(1, 2);
    }
}
//Để ý cách dùng dưới khác cách dùng trên vì khi dùng new với 1 contract or interface thì nó hiểu là đổi state var nên sẽ thành 1 transaction mất gas trong khi cách dùng trên thì k. Ta có thể gọi hàm gán new vào 1 hàm transaction duy nhất để gọi nó trc khi dung để chỉ gọi new 1 lần cho tiết kiệm

//interface có thể ké thừa; gọi trực tiếp tên của interface => khi đó nó như 1 hàm số nhận vào địa chỉ của contract để thực thi các hàm bên trong; tạo ra 1 biến instance của interface đó như ví dụ trên
// Chú ý 2 cách trên là độc lập k được dùng trộn kiểu: tạo 1 instance của interface với new nhưng contract đó lại kế thừa là sai
// Dùng ở xa, k kế thừa, dùng thông qua địa chỉ của contract
// Dùng cùng file, kế thừa, dùng thông qua instance từ khóa new -> or luôn luôn dùng như cách 1 tốt hơn vì tạo instance tốn gas

// # Basic / Dùng try catch
// try/catch chỉ là 1 cách khác của bắt lỗi như assert, revert, require
// try/catch chỉ dùng cho hàm external or contract creation. 
// => try <gọi function>(tham số) returns(nếu có) { giá trị trả về có thể dùng ở đây } => return của try là return của function
// External chỉ nên dùng ở 1 function để cho 1 contract khác gọi tới nó, nhưng thực tế, ta gọi external function trong contract hiện tại cx chả báo lỗi gì, nhưng phải dùng thêm this
contract Example {
    function exampleFunction(uint256 _a, uint256 _b) public returns (uint256 _c) {
        try this.exFunc() returns(uint number) {
            return number;
        } catch Error(string memory _err) {
            //handle error
        } catch (bytes memory _err) {
            //handle error
        }
    }
    function exFunc() external pure returns(uint){
        return 1;
    }
}


contract X{
    function test() public pure returns(uint) {
        return 1;
    }
    function test1() public pure returns(uint) {
        return test();
    }
    function test2() public view returns(uint) {
        return this.test();
    }
}
// Phân biệt: gọi hàm với this là đọc từ state phải dùng view, còn gọi trực tiếp thì như bth; gọi với this là gọi như 1 đối tượng từ ngoài gọi độc lập nên call được cả hàm external ở ngay trong chính function còn gọi trực tiếp
// Hàm bth k gọi được hàm external. VD test đổi thành external thì test1 sẽ báo lỗi
