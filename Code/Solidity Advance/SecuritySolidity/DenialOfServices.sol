// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// # Bảo mật Sol / DenialOfService

// Cơ chế game: ai gửi tiền vào trong KingOfEther, phải nhiều hơn khoản tiền mà king trước gửi vào thì người đó sẽ trở thành king mới và gửi lại tiền cho king cũ
contract KingOfEther {
    address public king;
    uint public balance;
    mapping(address => uint) public balances;

    // Người mới gửi lượng tiền lớn hơn king cũ để trở thành king mới
    function claimThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        // Gửi lại tiền cho king cũ luôn sẽ sai. Phải để họ tự withdraw
        // (bool sent, ) = king.call{value: balance}("");
        // require(sent, "Failed to send Ether");
        balances[king] += balance;

        balance = msg.value;
        king = msg.sender;
    }
    // King cũ vào withdraw
    function withdraw() public {
        require(msg.sender != king, "Current king cannot withdraw");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        // Ta set balance trước khi gửi để tránh reentrancy

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    KingOfEther kingOfEther;

    constructor(KingOfEther _kingOfEther) {
        kingOfEther = KingOfEther(_kingOfEther);
    }

    // You can also perform a DOS by consuming all gas using assert. This attack will work even if the calling contract does not check whether the call was successful or not 
    // => hay, vì assert ép dừng vì dùng hết, chứ dùng bth mà nó k check call thành công hay không thì vẫn pass qua
    // function () external payable {
    //     assert(false);
    // }

    function attack() public payable {
        kingOfEther.claimThrone{value: msg.value}();
    }
}
// Cơ chế attack: attacker gửi tiền vào contract attack forward tới KingOfEther, nó sẽ gửi tiền vào contract và trở thành king, đồng thời KingOfEther unusable vì nếu người sau gửi tiền vào 1 khoản lớn hơn nx thì trả lại tiền cho king cũ là contract attack
// Nhưng nó lại k có fallback function(từ chối dịch vụ) or có fallback nhưng lại assert false để k hoạt động thì sẽ trans sẽ fail. Hàm gửi trả tiền nằm trong claimThrone mà gửi tiền luôn fail nên hàm sẽ luôn fail
// Để khắc phục, ta dùng smart contract design push versus pull: đây là cơ chế design phổ biến của smart contract như trên. Thay vì gửi tiền lại cho mỗi người mà người đó từ chối dịch vụ k nhận tiền làm fail trans thì ta cho họ tự rút tiền của mình ở 1 hàm public mới chứ k để contract chủ động gửi nx là xong. Ở đây dùng mapping để 1 người gắn vs khoản tiền họ đc rút
