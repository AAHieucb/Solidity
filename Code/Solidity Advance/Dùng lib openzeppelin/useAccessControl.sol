// SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Context.sol";

// # Library / Dùng lib openzeppelin

contract UseAccessControl is Context, AccessControl{ // Chú ý kế thừa đúng thứ tự
    // Phải tạo kiểu này
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant ADMIN_MINTER_ROLE = keccak256("ADMIN_MINTER_ROLE");
    constructor(address minter1, address minter2, address burner) {
        // Contract kế thừa có thể gọi được các hàm internal nhưng k truy cập được biến private
        _setupRole(MINTER_ROLE, minter1);
        _setupRole(MINTER_ROLE, minter2);

        _setRoleAdmin(MINTER_ROLE, ADMIN_MINTER_ROLE); 
        _setupRole(ADMIN_MINTER_ROLE, minter2);
        // VD 100 người có role 1, ta muốn có 1 người là admin thì phải tạo role admin cho role 1 như trên. Thành viên có nhiều nhưng admin chỉ có 1, mỗi lần set là đổi admin. Ở đây thì người nào có role ADMIN_MINTER_ROLE sẽ là admin của những người có role MINTER_ROLE.

        _setupRole(BURNER_ROLE, burner);
        _setupRole(BURNER_ROLE, _msgSender());
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    function mint() public view {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        // Code mint
    }
    function burn() public view {
        require(hasRole(BURNER_ROLE, msg.sender), "Caller is not a burner");
        // Code burn
    }
    function testRole() public view onlyRole(MINTER_ROLE) {
        // msg.sender phải là role MINTER_ROLE mới gọi được hàm này
    }
    // Có nhiều loại role, mỗi loại role có 1 adminRole riêng. Mặc định tất cả admin role đều là 0x00 => ai là admin của role nào thì có thể: bỏ role của mình bằng renounceRole, cấp role cho người khác với grant, xóa role của ng khác trong cùng loại với revoke, setRoleAdmin. Role admin mà kp member thì cũng k thao tác được như member mà chỉ có những quyền đó
    // Nếu k sửa đổi gì thì role DEFAULT_ADMIN_ROLE 0x00 sẽ là role admin của mọi role khác. Ở trên có 2 minter ta đổi role admin của minter là ADMIN_MINTER_ROLE còn role admin của burn vẫn là mặc định DEFAULT_ADMIN_ROLE thì admin của burn là ông msg.sender còn admin của minter là minter2.
}
