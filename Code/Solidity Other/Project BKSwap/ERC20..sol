// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./interfaces/IERC20.sol";

contract TestTokenForBKSwap is IERC20 {
    string _name = "Test";
    uint _totalSupply = 10**20;
    string _symbol = "TST";
    uint _decimals = 18;
    address _owner;

    mapping(address => uint) tokensOf;
    mapping(address => mapping(address => uint)) allowancesOf;
    
    constructor() {
        _owner = msg.sender;
        tokensOf[_owner] += _totalSupply;
    }

    modifier validAddress(address _addr){
        require(_addr != address(0), "Invalid address");
        _;
    }

    modifier onlyOwner(address _addr){
        require(_addr == _owner, "You are not owner");
        _;
    }
    
    function transfer(address recipient, uint256 amount) public override validAddress(recipient) returns (bool) {
        require(tokensOf[msg.sender] >= amount, "You don't have enough token to transfer");
        tokensOf[msg.sender] -= amount;
        tokensOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override validAddress(spender) returns (bool) {
        allowancesOf[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) 
        public override validAddress(sender) validAddress(recipient) returns (bool) {
            require(allowancesOf[sender][msg.sender] >= amount, "Not enough allowances");
            require(tokensOf[sender] >= amount, "sender not enough money");

            tokensOf[sender] -= amount;
            tokensOf[recipient] += amount;
            allowancesOf[sender][msg.sender] -= amount;

            return true;
        }

    function changeOwner(address _newOwner) public onlyOwner(msg.sender) validAddress(_newOwner) returns(bool Success){
        _owner = _newOwner;
        return true;
    }
    
    function name() public view returns(string memory Name) {
        return _name;
    } 
    function decimals() public view returns(uint Decimals) {
        return _decimals;
    }
    function symbol() public view returns(string memory Symbol) {
        return _symbol;
    } 
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    } 
    function balanceOf(address account) public override view returns (uint256) {
        return tokensOf[account];
    }
    function allowance(address owner, address spender) public override view returns (uint256) {
        return allowancesOf[owner][spender];
    }
}
