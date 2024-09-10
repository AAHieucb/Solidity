// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./IERC20.sol";

contract MyFirstTokenInLife is IERC20 {
    string private _name = "Test";
    uint private _totalSupply = 10**20;
    string private _symbol = "TST";
    uint private _decimals = 20;
    address private _owner;
    bool private _isLocking = false;
    mapping(address => uint) tokensOf;
    mapping(address => mapping(address => uint)) allowancesOf;
    
    // Trong constructor k có visibility
    constructor() {
        _owner = msg.sender;
        tokensOf[_owner] += _totalSupply;
        uint chainId;
        assembly{
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256('EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'),
                keccak256(bytes(_name)),
                keccak256(bytes('1')),
                chainId,
                address(this)
            )
        );
        PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    }
    bytes32 DOMAIN_SEPARATOR;
    bytes32 PERMIT_TYPEHASH;
    mapping(address => uint) public nonces;

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

    function _approve(address owner, address spender, uint value) internal {
        allowancesOf[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) 
    external {
        require(deadline >= block.timestamp, 'EXPIRED');
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'UniswapV2: INVALID_SIGNATURE');
        _approve(owner, spender, value);
    }
}
