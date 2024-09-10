pragma solidity >=0.7.0 <0.9.0;

// # Mã hóa / encode

contract Third{
    uint public x;
    uint public y;
    
    address public owner;
    uint public createdAt;

    constructor(uint _x, uint _y) {
        x = _x;
        y = _y;
        owner = msg.sender;
        createdAt = block.timestamp;
    }
    
    function hashGotCollision(uint _x, string memory _str, address _addr) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_x, _str, _addr));
        // encodePacked nhận multi type trả ra bytes. 
        // keccake256 nhận bytes và hash fix size nó trả ra bytes32
    }
    
    function avoidCollision(string memory _str1, string memory _str2) public pure returns(bytes32) {
        // encodePacked có input: 1,23 = 12,3 sẽ coi là trùng nhau, nhưng encode thì không
        return keccak256(abi.encode(_str1, _str2));
    }
    // keccak256 nhận bytes làm input tạo ra bytes32 + abi.encodePacked sẽ nối các data lại và trả ra bytes -> dễ collision
    // abi.encode sẽ k nối lại nên k gây collision
}