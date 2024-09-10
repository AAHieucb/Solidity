// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "../interfaces/ILPToken.sol";

// LP token cần những hàm cơ bản của ERC20 bth để người sở hữu nó có quyền gửi đi trade khắp nơi nhưng riêng hàm mintTo kp ai cx gọi đc
contract LPToken is ILPToken{
    string public _name = "LP Token";
    uint private _totalSupply = 0;
    string public _symbol = "LP";
    uint public _decimals = 18;
    bytes32 DOMAIN_SEPARATOR;
    bytes32 PERMIT_TYPEHASH;
    mapping(address => uint) public nonces;

    mapping(address => uint) public tokensOf;
    mapping(address => mapping(address => uint)) public allowancesOf;
    
    constructor() {
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

    modifier validAddress(address _addr){
        require(_addr != address(0), "Invalid address");
        _;
    }
    
    // Lúc gọi hàm này thì địa chỉ hợp lệ r và chỉ cần gửi thôi. Phải check hết trong các hàm dưới trước khi dùng
    function mintTo(address to, uint amount) internal {
        _totalSupply += amount;
        tokensOf[to] += amount;
    }

    function transfer(address recipient, uint256 amount) public override validAddress(recipient) returns (bool) {
        require(tokensOf[msg.sender] >= amount, "You don't have enough token to transfer");
        tokensOf[msg.sender] -= amount;
        tokensOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
    function _approve(address owner, address spender, uint value) internal {
        allowancesOf[owner][spender] = value;
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

    // Sự khác biệt khi kế thừa và dùng interface. Kế thừa là dùng trực tiếp hàm của nó. Còn dùng interface là gọi theo kiểu tương tác với 1 contract khác. VD: kế thừa ta gọi 1 hàm của chính nó thì msg.sender kp là chính nó mà là ng gọi hàm gọi nó -> chú ý msg.sender 1 cái là contract, 1 cái là ng gọi khác nhau
    // Hàm này chỉ gọi ở trong contract này, bên ngoài muốn đốt phải tạo hàm khác
    function burnToken(uint _amount) internal returns(bool Success) {
        require(tokensOf[address(this)] >= _amount, "You don't have enough token to burn");
        tokensOf[address(this)] -= _amount;
        _totalSupply -= _amount;
        return true;
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
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) 
    external override {
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
