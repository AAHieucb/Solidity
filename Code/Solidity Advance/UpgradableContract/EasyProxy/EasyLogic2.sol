pragma solidity >=0.5.10;
import "./Data.sol";
contract Target2 is Data {
    event T2UpdateData(uint256 data);
    function calculate(uint256 a, uint256 b) external {
        _data = a * b;
        emit T2UpdateData(_data);
    }
}