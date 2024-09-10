// Tạo lại contract proxy nhưng k dùng assembly mà dùng hàm bậc cao của solidity. Tốn gas. Tạo cả owner để chỉ mình dev mới được upgrade contract
// Muốn update 1 contract, ta viết contract mới r dùng owner address thay địa chỉ, mọi thứ frontend phải gọi thông qua contract này

// # Upgradable contract

pragma solidity >=0.5.10;
import "./Data.sol";
contract Proxy is Data {
    // Owner's address
    address private _owner;
    // Contract's address
    address private _contractAddress;
    // Only owner modifier
    modifier onlyOwner {
        require(_owner == msg.sender, "Proxy: Caller wasn't owner");
        _;
    }
    // Update new smart contract
    event UpdateContractAddress(address indexed newContractAddress);
    // Get contract's address
    // Thêm id vào đằng sau để tạo ra signature của function chắc chắn khác các function trong contract gốc
    function getContract_58378af393c6() external view returns(address) {
        return _contractAddress;
    }
    // Get owner's address
    function getOwner_8e15c28d0fdc() external view returns(address) {
        return _owner;
    }
    // Change owner address
    function changeOwner_c6636e06d221(address newOwner) external onlyOwner {
        _owner = newOwner;
    }
    // Change smart contract
    function changeContract_75b73cc2c1eb(address newContractAddress) external onlyOwner {
        _contractAddress = newContractAddress;
        emit UpdateContractAddress(newContractAddress);
    }
    // Constructor function
    constructor (address contractAddress) public {
        _owner = msg.sender;
        _contractAddress = contractAddress;
        emit UpdateContractAddress(contractAddress);
    }
    // Fallback function
    function () external payable {
        bool successCall = false;
        bytes memory retData;
        (successCall, retData) = _contractAddress.delegatecall(msg.data);
        require(successCall, "Proxy: Internal call was failed");
    }
}