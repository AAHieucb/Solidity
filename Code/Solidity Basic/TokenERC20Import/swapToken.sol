pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

// A tạo contract với 1 lượng token muốn giao dịch ở 2 bên và thực hiện setAllowance cho contract. B cx set setAllowance nhưng phải set đủ lượng amount2 mà A đã set và cx có thể check xem A có setAllowance đủ k r ms set. B set xong thì thực hiện giao dịch luôn
// Đã set approve r k bỏ đc, trừ khi set lại thành 0
contract TokenSwap{
    IERC20 public token1;
    // Đây chính là cách thao tác với token ERC20 trong smart contract luôn, tương tự với mọi token khác, ta cứ tạo instance interface như này
    IERC20 public token2;
    address public address1;
    address public address2;
    uint public amount1;
    uint public amount2;
    constructor(address _token1, address _token2, address _addr1, address _addr2, uint _amount1, uint _amount2) {
        token1 = IERC20(_token1); // Cách lấy contract ở 1 địa chỉ
        token2 = IERC20(_token2);
        address1 = _addr1;
        address2 = _addr2;
        amount1 = _amount1;
        amount2 = _amount2;
    }
    function swap() public {
        require(msg.sender == address1 || msg.sender == address2, "You are not authorized");
        require(token1.allowance(address1, address(this)) >= amount1, "Not enough");
        require(token2.allowance(address2, address(this)) >= amount2, "Not enough");
        safeTransferFrom(token1, address1, address2, amount1);
        safeTransferFrom(token2, address2, address1, amount2);
    }
    // Biến contract hay interface truyền trực tiếp vào hàm đc
    function safeTransferFrom(IERC20 token, address from, address to, uint amount) internal {
        bool isSent = token.transferFrom(from, to, amount);
        // Nhớ hàm transferFrom trả ra boolean
        require(isSent, "send failed");
    }
    
}