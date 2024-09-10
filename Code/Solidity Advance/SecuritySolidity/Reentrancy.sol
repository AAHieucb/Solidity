// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// # Bảo mật Sol / Cản reentrancy hack

contract EtherStore {
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // C2 là dùng modifier để chống reentrancy, đặt cái này ở mọi hàm cần BV
    bool internal locked; // Chỉ cần internal
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function withdraw() public noReentrant {
        uint bal = balances[msg.sender];
        require(bal > 0);

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
        // Cách fix 1 là update state trước khi thực hiện call liên quan đến 1 contract khác vì ta k tin tưởng bất cứ 1 hàm của contract nào cả, luôn phải biết rằng 1 contract lạ luôn có khả năng đưa hàm gọi nó vào vòng lặp vô tận => đưa dòng này lên trước khi call
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    fallback() external payable {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
