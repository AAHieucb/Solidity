pragma solidity >=0.7.0 <0.9.0;
/*
cơ chế:
tạo token: khởi tạo; cung 1 lượng 1 ban đầu; số dư có tiền
gửi token: người nhận; số lượng token gửi
*/

contract Firstcoin{
    // # Basic
    address public minter;
    mapping (address => uint) public balances;
    event sent(address indexed from, address to, uint amount);
    
    modifier onlyMinter{
        require(msg.sender == minter, "You are not minter");
        assert(msg.sender == minter); //k có đối số 2
        //mục đích của modifier là tái sử dụng nhiều nơi mà thôi
        _;
    }
    modifier checkAmount(uint amount){
        require(amount <= balances[minter],"Not enough money");
        _; //cái này là nếu đk thỏa mãn sẽ thực hiện tiếp phần code tiếp theo
    }
    
    constructor(){ // thực hiện ! 1 lần tự động
        minter = msg.sender;
        // msg sender là biến global chỉ người gửi cái lệnh đi. Đó là người khởi tạo luôn
        // balances[msg.sender] += 10000; // dùng mẹ nó ở đây cx đc
    }
    function mint(address receiver, uint amount) public onlyMinter{
        // Phải thỏa mãn onlyMinter đầu tiên r mới chạy hàm bên trong
        require(amount < 1e60, "amount excess"); // chơi 1e60 như C++ được, tiện dụng khi muốn có 1 số lớn
        balances[receiver] += amount;
    }

    // Ta thực hiện khởi tạo contract thì minter sẽ có 1 khoản tiền. Đây là hàm chuyển tiền từ minter cho receiver
    function send(address receiver, uint amount) public checkAmount(amount){
        balances[minter] -= amount;
        balances[receiver] += amount;
        emit sent(minter, receiver, amount);
    }
}
