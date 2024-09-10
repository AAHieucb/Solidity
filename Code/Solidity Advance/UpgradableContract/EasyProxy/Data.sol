pragma solidity >=0.5.10;
contract Data {
    // Data store and accessible
    uint256 internal _data;
    // Method to access data
    function data() public view returns(uint256) {
        return _data;
    }
}