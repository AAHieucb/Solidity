pragma solidity >=0.7.0 <0.9.0;

// # Cách gọi hàm của 1 contract khác chuẩn / Cách chuẩn dùng interface + address
contract Callee{
    uint public x;
    uint public value;
    function NormalFunction(uint _x) public returns(uint){
        x = _x;
        return x;
    }
    function PayableFunction(uint _x) public payable returns(uint,uint){
        x = _x;
        value = msg.value;
        return(x, value);
    }
}

contract Caller{
    function callNormalFunction(Callee callee, uint _x) public {
        uint x = callee.NormalFunction(_x);
        /*calle.call(abi.encodeWithSignature("NormalFunction(uint256)", _x));*/
    }
    // Điều này đồng nghĩa xh 1 kiểu biến mới type là <tên Contract> -> cx chỉ là địa chỉ thôi
    // Kiểu truyền tên này chỉ đúng khi cùng trong cái file này or đc embed vào file này chứ nếu k thì truyền vào địa chỉ đơn giản và gọi call or tạo interface trong file này
    function callFromAddress(address addr, uint _x) public payable{
        Callee callee = Callee(addr);
        (uint x, uint value) = callee.PayableFunction{value: 1 ether}(_x);
        // Chú ý value của hàm PayableFunction nên phải viết sau nó. Ta gửi ether vào contract và gửi tiếp cho callee. Ở đây gửi 1 ether, nếu ether contract này có ít hơn sẽ báo lỗi
        // Nếu dùng call thì k tồn tại tự gọi vào fallback, nếu dùng tạo 1 instance của contract dựa vào địa chỉ thì hàm k tồn tại sẽ báo lỗi, như v ta sẽ biết luôn, chứ dùng call thì phải deploy contract xong r gọi mới biết là hàm k tồn tại, lúc đó k sửa đc nx r
        // Do đó cách này k dùng gọi fallback mà phải call mới gọi đc fallback VD ở trên mà contract tên Callee k có hàm PayableFunction thì sẽ báo lỗi
    }
}

// Nếu có 1 contract khác trong file có hàm tên giống như contract cần gọi thì khi truyền địa chỉ của nó, nó sẽ gọi hàm đó bất kể ta đặt khác tên contract => ta k nên tin tưởng bất cứ 1 hàm nào mà ta k sở hữu vì có thể gọi ra kết quả k mong muốn. Tức tên contract thực sự chỉ là 1 address bth
// Nó ưu tiên gọi theo địa chỉ truyền vào chứ tên contract qtr gì
contract Foo{
    uint public x;
    function NormalFunction(uint _x) public returns(uint){
        x = _x + 1;
        return x;
    }
}
