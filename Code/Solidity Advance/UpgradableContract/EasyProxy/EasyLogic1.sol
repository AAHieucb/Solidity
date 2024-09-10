pragma solidity >=0.5.10;
import "./Data.sol";
contract Target1 is Data {
    event T1UpdateData(uint256 data);
    function calculate(uint256 a, uint256 b) external {
        _data = a + b;
        emit T1UpdateData(_data);
    }
}