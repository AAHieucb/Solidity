pragma solidity >=0.7.0 <0.9.0;

// # Dùng transfer, send, call

contract ReceiveEther{
    event Log(uint gas);
    event Received(address caller, uint amount, string message);
    // Tạo hàm fallback no input, no ouput, external cho 1 contract. Có cái này mới nhận được ether từ transaction khác
    // Trong fallback thg k viết gì cả vì nếu dùng transfer or send sẽ chỉ cho 2300 gas chỉ đủ cho 1 event Log. Cx k thể call another contract or write vào storage, nếu làm v thì transaction sẽ fail. Default nó trống
    fallback () external payable {
        emit Log(gasleft());
        emit Received(msg.sender, msg.value, "call fallback");
        // 1 contract call hàm contract khác thì msg.sender là địa chỉ contract gọi hàm
    }
    // 1 fallback function được gọi trong 2 TH: khi gọi 1 hàm số k tồn tại(tự chạy cái này thay thế); khi send ether cho contract bằng send, transfer, call
    // Nếu mục đích là để contract này có thể nhận ether thì mới cần có payable như ở TH này
    
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    function foo(string memory _message, uint _x) public payable returns(uint) {
        emit Received(msg.sender, msg.value, _message);
        return _x + 1;
    }
}

contract SendEther{
    // Dùng hàm này: set value của account -> điền địa chỉ nơi nhận(là contract bên trên) -> gọi hàm đầu tiên payable sẽ gửi ether từ tài khoản vào contract này, r lại gửi từ contract này sang contract trên. Để contract trên nhận được, nó sẽ tự chạy vào hàm fallback 
    function sendViaTransfer(address payable _to) public payable {
        _to.transfer(msg.value); // Bay 2300 gas, throw error nếu fail
    }
    function sendViaSend(address payable _to) public payable {
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send ether"); // Trả ra bool nên phải tự check, thất bại sẽ undone. Nếu k check mà gửi k thành công sẽ chả thông báo gì
    }
    function sendViaCall(address payable _to) public payable {
        (bool sent, bytes memory data) = _to.call{value: msg.value, gas: 5000}(""); // Mặc định sẽ dùng hết 5000 gas trả ra bool thành công hay k và data là giá trị bytes trả về từ fallback function, ở đây là 0 byte
        require(sent, "Failed to send ether");
    }
    
    event Response(bool success, bytes data);
    // call được dùng để gọi vào bất cứ hàm nào của 1 contract khác, chẳng qua hàm fallback là hàm giúp contract nhận ether nên mới được sử dụng để gửi ether bằng cách gọi vào 1 hàm không tồn tại của contract mà thôi
    // 1 function là payable ta có thể k truyền ether cho nó, nó vẫn thực hiện bên trong bth và k nhận ether thôi
    // VD ta gọi vào fallback mà k gửi tiền(gọi vào 1 payable function từ 1 function k payable thoải mái)
    function callFuncDoesNotExist(address _to) public {
        (bool success, bytes memory data) = _to.call(
            abi.encodeWithSignature("doesnotexist()") // abi cho phép truy cập vào smart contract
            // abi.encodeWithSignature trả ra kiểu bytes là đối số truyền vào hàm call để chỉ định gọi hàm gì.
        );
        // Đây là cách gọi bất cứ 1 hàm nào bth, nếu thích ta chỉ cần call{}("") cũng tự gọi fallback r
        emit Response(success, data);
    }
    function callFuncExist(address _to) public payable {
        (bool success, bytes memory data) = _to.call{value: msg.value, gas: 5000}(
            abi.encodeWithSignature("foo(string,uint256)","call foo", 123)  
            // K có space trong string, uint là viết tắt của uint256 và trong string ta phải viết rõ uint256
        );
        emit Response(success, data); // 1 cách xem giá trị biến (1 cách để log data debug contract)
        // data nhận được là 0x000000000000000000000000000000000000000000000000000000000000007c là hexadecimal của 124 => parseInt để lấy gía trị => Tức gọi bằng call cho ta lấy giá trị trả về của function và thực hiện tiếp
    }
}
// Chú ý là dùng call để gọi 1 function khác là unrecommended vì dùng string như trên dễ sai dẫn đến fallback được gọi, ta sẽ học cách chuẩn để gọi 1 hàm trong contract khác ở bài sau còn call chỉ dùng để send ether
