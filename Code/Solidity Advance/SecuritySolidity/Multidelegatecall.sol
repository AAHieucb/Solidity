// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// # Minimal Proxy Contract / Dùng multi delegatecall

contract MultiDelegatecall {
  error DelegatecallFailed();
  function multiDelegatecall(
    bytes[] memory data
  ) external payable returns (bytes[] memory results) {
    results = new bytes[](data.length);
    for (uint i; i < data.length; i++) {
      (bool ok, bytes memory res) = address(this).delegatecall(data[i]);
      if (!ok) {
        revert DelegatecallFailed();
      }
      results[i] = res;
    }
  }
}

contract TestMultiDelegatecall is MultiDelegatecall {
  event Log(address caller, string func, uint i);

  // Dùng multi delegatecall có thể đảm bảo msg.sender là người dùng
  function func1(uint x, uint y) external {
    emit Log(msg.sender, "func1", x + y);
  }

  function func2() external returns (uint) {
    emit Log(msg.sender, "func2", 2);
    return 111;
  }

  mapping(address => uint) public balanceOf;

  // Dùng multidelegate call giúp gọi nhiều hàm thành 1tx rất nguy hiểm.
  // Gọi hàm mint 3 lần trong 1tx nhờ multidelegatecall truyền 1ETH, nó lại tưởng ta mint 3 lần độc lập vì msg.value cả 3 đều là 1ETH
  function mint() external payable {
    balanceOf[msg.sender] += msg.value;
  }
}

contract Helper {
  function getFunc1Data(uint x, uint y) external pure returns (bytes memory) {
    return abi.encodeWithSelector(TestMultiDelegatecall.func1.selector, x, y);
  }

  function getFunc2Data() external pure returns (bytes memory) {
    return abi.encodeWithSelector(TestMultiDelegatecall.func2.selector);
  }

  function getMintData() external pure returns (bytes memory) {
    return abi.encodeWithSelector(TestMultiDelegatecall.mint.selector);
  }
}
