pragma solidity >=0.8.0;

// # Upgradable contract / Dùng proxy contract với assembly

contract SampleProxy {
    constructor (address _logic, bytes memory _data) public payable {
        // Check tuân theo chuẩn eip1967. Nếu sau này dùng cứ đúng vị trí bộ nhớ đó mà quất
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        _setImplementation(_logic);
        // VD có hàm init thì gọi luôn ở đây được. VD: 0x8129fc1c là selector của hàm initialization of SampleLogic
        if(_data.length > 0) {
            // solhint-disable-next-line avoid-low-level-calls
            (bool success,) = _logic.delegatecall(_data);
            require(success);
        }
    }

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    // Vị trí lưu bộ nhớ. Vì dùng assembly quản lý bộ nhớ tối ưu, ta vào 1 vị trí random ở xa để kbh trùng
    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function _implementation() internal view returns (address impl) {
        bytes32 slot = _IMPLEMENTATION_SLOT;
        // solhint-disable-next-line no-inline-assembly
        // Load cái ô nhớ đó
        assembly {
            impl := sload(slot)
        }
    }

    function _fallback() internal {
        _delegate(_implementation());
    }

    function _delegate(address implementation) internal {
        // Cơ chế: Tạo ra 1 vùng nhớ fix 32 bytes trên mem lưu địa chỉ của contract. 
        // Mỗi lần gọi sẽ forward msg.data vào memory vị trí 0 chứa thông tin hàm và params rồi gọi call contract với data đó bằng delegatecall.

        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    // Upgrade địa chỉ contract mới 
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable {
        _upgradeTo(newImplementation);
        // // solhint-disable-next-line avoid-low-level-calls
        // (bool success,) = newImplementation.delegatecall(data);
        // require(success);
    }

    /**
     * @dev Upgrades the proxy to a new implementation.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {

        bytes32 slot = _IMPLEMENTATION_SLOT;

        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newImplementation)
        }
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback () external payable {
        _fallback();
    }
}
