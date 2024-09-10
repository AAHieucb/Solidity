// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./interfaces/IFactory.sol";
import "./Pair.sol";
import "./libraries/TokensUltility.sol";

// Quy ước: gạch chân dưới là utility or đối số truyền vào hàm bị trùng tên
contract Factory is IFactory{
    address public override addrReceiveFee;
    Pair[] public pairs;
    
    mapping(address => mapping(address=>uint)) public indexOfPair;
    
    constructor(address _addrReceiveFee){
        addrReceiveFee = _addrReceiveFee;
        pairs.push(Pair(address(0)));
    }
    function getNumberOfPairs() external view override returns(uint){
        return pairs.length - 1;
    }
    function getAddressOfPairs(address _token1, address _token2) external view override returns(address){
        (address realToken1, address realToken2) = TokensUltility.sortTokens(_token1, _token2);
        return address(pairs[indexOfPair[realToken1][realToken2]]);
    }
    function createPair(address _token1, address _token2) external override returns(address) {
        require(_token1 != _token2, "SAME TOKEN");
        // Tạo cặp pair -> create2 k hoạt động
        // bytes memory bytecode = abi.encodePacked(type(Pair).creationCode, abi.encode(_token1, _token2));
        // bytes memory salt = abi.encodePacked(_token1, _token2);
        // address addr;
        // assembly{
        //     addr := create2(callvalue(), add(bytecode, 32), mload(bytecode), salt)
        // }
        (address realToken1, address realToken2) = TokensUltility.sortTokens(_token1, _token2);
        Pair addr = new Pair(realToken1, realToken2);
        indexOfPair[realToken1][realToken2] = pairs.length;
        
        // Lưu vào pair
        pairs.push(addr);
        emit NewPair(address(addr));
        return address(addr);
    }
}
