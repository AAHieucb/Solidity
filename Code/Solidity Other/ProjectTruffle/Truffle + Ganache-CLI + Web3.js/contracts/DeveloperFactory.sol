// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 < 0.9.0;

contract DeveloperFactory {
    event NewDeveloper(uint devId, string name, uint age);

    uint maxAge = 100;
    uint minAge = 5;

    struct Developer {
        string name;
        uint id;
        uint age;
    }

    Developer[] public developers;

    mapping (uint => address) public devToOwner;
    mapping (address => uint) public ownerDevCount;

    function _createDeveloper(string memory _name, uint _id, uint _age) private {
        uint id = _id;
        developers.push( Developer( _name, _id, _age ) );
        ownerDevCount[msg.sender]++;
        devToOwner[id] = msg.sender;
        emit NewDeveloper(id, _name, _age);
    }

    function _generateRandomId( string memory _str ) private pure returns (uint){
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand;
    }

    function createRandomDeveloper( string memory _name, uint _age ) public payable {
        require(_age > minAge);
        require(_age < maxAge);
        require(msg.value == 5000000000000000000);
        uint randId = _generateRandomId( _name );
        _createDeveloper(_name, randId, _age );
    }

    function getAllDevelopers() public view returns (uint) {
        return developers.length;
    }

    function sayHello() public pure returns(string memory){
        return "Hello World";
    }
}