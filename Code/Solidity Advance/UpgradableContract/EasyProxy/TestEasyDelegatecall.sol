pragma solidity >=0.8.0;

// # Upgradable contract

contract StorageContract {
    address public sender;
    uint256 public balance;
}

contract A is StorageContract {
    function delegateCallToB(address _contractLogic, uint256 _balance) external {
        (bool success, ) =  _contractLogic.delegatecall(abi.encodePacked(bytes4(keccak256("setBalance(uint256)")), _balance));
        require(success, "Delegatecall failed");
    }
}

contract B is StorageContract {
    function setBalance(uint256 _balance) external {
        sender = msg.sender;
        balance = _balance;
    }
}

contract C is StorageContract {
    function setBalance(uint256 _balance) external {
        sender = msg.sender;
        balance = balance + _balance * 2;
    }
}
// Với các contract đơn giản dùng thuần delegatecall(chưa nói gì về proxy) thì họ làm kiểu này tức là họ muốn upgrade contract A thì từ ban đầu dùng delegatecall cho nó. Vc cho logic 1 contract riêng kế thừa từ contract lưu state là 1 pattern tốt để đảm bảo mọi contract logic k bị sai thứ tự các biến state
// Nó k thích hợp dự án lớn và khó khăn khi quản lý biến private, storage contract phải có đủ các hàm set get cần thiết. Đây là cách triển khai đơn giản nhất là Inherited Storage