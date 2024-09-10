pragma solidity >=0.7.0 <0.9.0;

// # Minimal Proxy Contract
// call và delegatecall đều là low-level function
// Khi gọi delegatecall điểm khác biệt duy nhất là msg.sender, msg.value, storage(lưu các state var) sẽ dùng giá trị của contract caller đã gọi delegatecall => tạo ra upgradable contract k cần sửa code và deploy lại

contract B{
    // Chú ý các state var phải đúng thứ tự như trong contract A nếu k sẽ mess up state var contract A
    uint public num;
    address public sender;
    uint public value;
    function setVar(uint _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
    // Khi dùng delegate call thì msg.sender ở đây là user gọi hàm gọi delegatecall thì biến sender của contract A sẽ là user => nó kiểu copy code vào contract A ấy
    // Khi dùng call thì biến sender của contract B được gán là địa chỉ contract A
}

// contract B có vai trò như 1 version xử lý các hàm như setVar. Sau này có các version khác chỉ cần đổi địa chỉ là đc => các hàm nào trong contract muốn có khả năng upgradable thì phải xác định dùng delegatecall ngay từ đầu. Contract A bên dưới nên thêm only owner vào vì như v ai cũng update hàm đc -> chỉ update các hàm mà chỉ owner dùng

contract BVersion2{
    uint public num;
    address public sender;
    uint public value;
    function setVar(uint _num) public payable {
        num = 2*_num;
        sender = msg.sender;
        value = msg.value;
    }
}

contract A{
    uint public num;
    address public sender;
    uint public value;
    function testDelegateCall(address b, uint _num) public payable{
        (bool success, bytes memory data) = b.call(
            abi.encodeWithSignature("setVar(uint256)",_num)   
        );
        // dùng call: statevar của B đổi, A k đổi
        // dùng delegate call: statevar của B k đổi, của A đổi
    }
}
