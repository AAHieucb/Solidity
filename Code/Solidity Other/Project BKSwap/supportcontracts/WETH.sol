// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../interfaces/IWETH.sol";

// WETH là 1 token ERC20 nhưng nó k có giá trị trao đổi gì khác mà chỉ phục vụ cho Router đổi qua ETH mà thôi nên ta sẽ lược đi nh hàm k dùng
contract WETH is IWETH{
    string public _name = "WETH Token";
    uint private _totalSupply = 0;
    string public _symbol = "WETH";
    uint public _decimals = 18;
    event checkBalance(string data, uint amount);

    mapping(address => uint) public tokensOf;
    mapping(address => mapping(address => uint)) public allowancesOf;
    
    constructor() {
    }

    modifier validAddress(address _addr){
        require(_addr != address(0), "Invalid address");
        _;
    }
    
    // Khi gọi hàm này phải truyền vào cho nó 1 lượng ETH payable
    function swapToWETH() public payable override {
        uint amount = msg.value;
        emit checkBalance("Balance of Router WETH", address(this).balance);
        _totalSupply += amount;
        tokensOf[msg.sender] += amount;
    }
    event check1(uint amount);
    function swaptoETH(uint amount) public override {
        require(tokensOf[msg.sender] >= amount && amount > 0, "NOT ENOUGH");
        _totalSupply -= amount;
        tokensOf[msg.sender] -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "FAIL TRANSFER");
        emit checkBalance("Balance of Router WETH", address(this).balance);
        emit check1(amount);
    }

    function transfer(address recipient, uint256 amount) public override validAddress(recipient) returns (bool) {
        require(tokensOf[msg.sender] >= amount, "You don't have enough token to transfer WETH");
        tokensOf[msg.sender] -= amount;
        tokensOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
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
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    } 
    function balanceOf(address account) public override view returns (uint256) {
        return tokensOf[account];
    }
}
