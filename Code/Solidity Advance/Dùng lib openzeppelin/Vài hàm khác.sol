pragma solidity >=0.8.0;

contract A {
    // # Basic / Dùng các biến có sẵn
    function get1() public view returns(uint){
        return block.number;
    }
    function get2() public view returns(uint){
        return block.timestamp;
    }
    function getCreateCode() public pure returns(bytes memory){
        return type(B).creationCode;
    }
    function test() public view returns(uint) {
        return mulmod(5, 3, 10); // Nhân r chia lấy mod
    }
    function getMax() public view returns(uint){
        return type(uint).max;//lấy ra 2**256 - 1
    }
}

contract B{
    
}