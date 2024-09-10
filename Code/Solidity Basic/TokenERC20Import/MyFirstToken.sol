// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./ERC20.sol";

// # Token Ethereum
contract MyFirstTokenInLife is IERC20 {
    string private _name = "Test";
    uint private _totalSupply = 10**20;
    string private _symbol = "TST";
    uint private _decimals = 20;
    address private _owner;
    bool private _isLocking = false;

    mapping(address => uint) tokensOf;
    mapping(address => mapping(address => uint)) allowancesOf;
    
    // Trong constructor k đc dùng các visibility vì nó chỉ đc deploy 1 lần hiển nhiên nhìn thấy nên dùng sẽ k có effect j
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

    modifier checkIsLocking(){
        require(_isLocking == false, "Token is locking, cannot transfer!");
        _;
    }

    // Code đứng từ phía 1 người dùng bất kỳ nào đó sử dụng, chạy dòng code này kp là owner j hết
    function transfer(address recipient, uint256 amount) public override validAddress(recipient) checkIsLocking returns (bool) {
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
        public override validAddress(sender) validAddress(recipient) checkIsLocking returns (bool) {
            require(allowancesOf[sender][msg.sender] >= amount, "Not enough allowances");
            require(tokensOf[sender] >= amount, "sender not enough money");

            tokensOf[sender] -= amount;
            tokensOf[recipient] += amount;
            allowancesOf[sender][msg.sender] -= amount;

            return true;
        }

    function burnToken(uint _amount) public returns(bool Success) {
        require(tokensOf[msg.sender] >= _amount, "You don't have enough token to burn");
        tokensOf[msg.sender] -= _amount;
        _totalSupply -= _amount;
        return true;
    }

    function lockToken() public onlyOwner(msg.sender) returns(bool IsLocking){
        _isLocking = !_isLocking;
        return _isLocking;
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

    function getOwnerNow() public view returns(address Owner){
        return _owner;
    }
    function balanceOf(address account) public override view returns (uint256) {
        return tokensOf[account];
    }
    function allowance(address owner, address spender) public override view returns (uint256) {
        return allowancesOf[owner][spender];
    }
}

