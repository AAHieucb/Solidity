pragma solidity >=0.7.0 <0.9.0;

contract X{
    address public testVar = 0x0000000000000000000000000000000000000001;
    event Log(string mess);
    string public name;
    constructor(string memory _name) {
        name = _name;
        emit Log(_name);
    }
}
// Dùng event là có đổi state nên k đc dùng view hay pure. 
// 2 contract trong cùng 1 file k được có cùng tên event => vẫn được mà

contract Y{
    event Log1(string mess);
    string public text;
    constructor(string memory _text) {
        text = _text;
        emit Log1(_text);
    }
}
contract A is X("Fixed Input"),Y {
    constructor(string memory _text) Y(_text) {
        testVar = 0x0000000000000000000000000000000000000002;
        // Để đổi state var của 1 contract mà var ở parent thì chỉ được reassign trong hàm chứ solidity k cho định nghĩa override biến
    }
    function testExternal() external view returns(address){
        return testVar; // Hàm này chỉ có trans khác truy cập vào đc. Trong contract A và con của nó k thể gọi do đó public, internal, private có thể dùng với state var chứ k có external state var
    }
}
contract B is Y, X{
    constructor(string memory _name) X(_name) Y("Fixed Input") {
        // constructr Y được gọi trước X, riêng khi khởi tạo sẽ theo thứ tự kế thừa ngược với thứ tự gọi hàm như trước 
    }
}
