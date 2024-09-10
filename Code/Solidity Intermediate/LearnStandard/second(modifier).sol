pragma solidity >=0.7.0 <0.9.0;

// # Basic

contract Second{
    address public owner;
    constructor(){
        owner = msg.sender;
    } // K có public ở constructor
    modifier onlyOwner(){
        require(msg.sender == owner, "Not Owner");
        _;
    } // Fùng _; tức là bảo solidity thực hiện tiếp các lệnh tiếp theo tròng hàm vì chạy đến đây tức là thỏa mãn require r
    modifier validAddress(address _addr){
        require(_addr != address(0), "Not a valid address");
        _;
    }
    function changeOwner(address _newOwner) public onlyOwner validAddress(_newOwner){
        owner = _newOwner;
    } // Thay vì dùng modifier, ta tạo function check r gọi function đó cx đc
    
    // # Bảo mật Sol / Cản reentrancy hack
    // Reentrancy hack là hiện tượng gọi loop nhau, A gọi B và trong B gọi A hay 1 hàm gọi đệ quy. Để ngăn chặn điều này ta có thể dùng modifier. VD ta ngăn hàm gọi đệ quy như dưới
    bool locked = false;
    uint public x = 10;
    modifier stopRecursion(){
        require(!locked, "Locked");
        locked = true;
        _;
        locked = false;
    }
    function decrement(uint i) public stopRecursion {
        x -= i;
        if(i > 1){
            decrement(i - 1);
        }
    }
    // Cơ chế: decrement truyền 3 vào chẳng hạn -> hàm sẽ đổi state var x = x - 3 xong 3 >= 1 thì x = x - 2 xong x = x - 1
    // Nó cứ gọi lại decrement như v là đệ quy. Ta tạo 1 modifier khiến cho các hàm đệ quy sẽ k được thực thi nx bằng cách thực hiện lần đầu thì locked = true và hàm _; gọi các hàm bên trong. Nếu bên trong gọi đệ quy thì lần này locked = true mất r và undone hết => tức là hàm _; sẽ k được gọi lại hàm hiện tại
}