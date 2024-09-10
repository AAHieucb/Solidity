// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract UserData{
    struct Info{
        int id;
        uint age;
        string name;
        string description;
        string avatar;
    }
    address public owner;
    address[] public listAddress;
    mapping(address => Info) public data;
    constructor(){
        owner = msg.sender;
    }
    event Deposit(address sender, uint value);
    receive() external payable{
        emit Deposit(msg.sender, msg.value);
    }
    fallback() external payable{ }
    function withdraw() public {
        require(msg.sender == owner, "Not Owner");
        require(address(this).balance > 0, "Contract have no ether");
        (bool success, ) = owner.call{value: address(this).balance}("0x00");
        require(success, "Cannot withdraw");
    }
    function getNumberOfUser() public view returns(int) {
        return int(listAddress.length);
    }
    event AddCurrent(uint indexed age, int indexed id, string name, string description, string avatar, address indexed newAddress);
    function addCurrent(uint age, string memory name, string memory description, 
    string memory avatar, address newAddress) public {
        require(msg.sender == newAddress, "Not you");
        require(newAddress != address(0), "Not exist address");
        require(data[newAddress].id == 0, "User existed");
        listAddress.push(newAddress);
        int id = getNumberOfUser() + 1;
        data[newAddress] = Info(getNumberOfUser() + 1, age, name, description, avatar);
        emit AddCurrent(age, id, name, description, avatar, newAddress);
    }
    function updateInfo(uint age, string memory name, string memory description, 
    string memory avatar, address newAddress) public {
        require(msg.sender == newAddress, "Not you");
        require(data[newAddress].id != 0, "User existed");
        data[newAddress] = Info(data[newAddress].id, age, name, description, avatar);
        emit AddCurrent(age, data[newAddress].id, name, description, avatar, newAddress);
    }
    function getUser(address addr) public view returns(Info memory){
        return data[addr];
    }
    function deposit() public payable { }
}