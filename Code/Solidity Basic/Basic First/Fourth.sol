pragma solidity >0.7.0 <0.9.0;

contract Test{
    // # Basic / Keyword payable
    string public testStr;
    function nothing() public payable returns (bool){
        if(msg.value == 0){
            revert("stop program");
        }
        testStr = "Hello World";
        return true;
    }
    // payable là 1 keyword, phải có nó thì function mới trao đổi được ether. Nó sẽ chuyển sang màu đỏ trong remix mà ta có thể đổi value trong deploy để giao dịch với ether.
    // Trong các file đầu thì ta k thực sự dùng tiền mà chỉ đơn giản cộng trừ 1 lượng uint mà ta quy ước
    // trong hàm map. Vd ở TH này số tiền msg.value khi gọi function này sẽ truyền vào address của contract này
}