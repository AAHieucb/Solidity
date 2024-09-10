pragma solidity ^0.8.0;

// Sàn có vai trò deploy contract và sở hữu luôn 1 lượng token gốc của nó. Người dùng có thể buy token sở hữu bởi sàn or sell token trên sàn: ủy thác sàn dùng 1 lượng token -> thực hiện lấy ether của sàn và trả lại sàn token

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    // event k cần khai báo lại ở contract cha
}


contract ERC20Basic is IERC20 {
    string public constant name = "ERC20Basic";
    string public constant symbol = "ERC";
    uint8 public constant decimals = 18;

    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    uint256 totalSupply_ = 10 ether;

    using SafeMath for uint256;

    constructor() public {
        balances[msg.sender] = totalSupply_;
    }

    function totalSupply() public override view returns (uint256) {
    return totalSupply_;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract DEX {
    event Bought(uint256 amount);
    event Sold(uint256 amount);

    IERC20 public token;

    constructor() public {
        // Sàn deploy token và sở hữu token. Để deploy dùng new là được
        token = new ERC20Basic();
    }

    // Người dùng mua token của sàn, gửi tiền cho sàn qua payable function
    function buy() payable public {
        uint256 amountTobuy = msg.value;
        uint256 dexBalance = token.balanceOf(address(this));
        require(amountTobuy > 0, "You need to send some ether");
        require(amountTobuy <= dexBalance, "Not enough tokens in the reserve");
        // Sàn trả lại 1 lượng token, ở đây là = 1 ETH luôn
        token.transfer(msg.sender, amountTobuy);
        emit Bought(amountTobuy);
    }

    // Người dùng bán token
    function sell(uint256 amount) public {
        require(amount > 0, "You need to sell at least some tokens");
        // approve cho sàn dùng 1 lượng token từ trước. transferFrom trả ra boolean mà, có thể gọi luôn rồi require(result) chứ check ở ngoài xong trong transferFrom lại check tiếp à
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= amount, "Check the token allowance");
        // Chuyển token cho sàn
        token.transferFrom(msg.sender, address(this), amount);
        // Sàn chuyển lại tiền
        payable(msg.sender).transfer(amount);
        emit Sold(amount);
    }
}
// Ta cho token bằng bao nhiêu ETH cố định ở đây chứ kp bằng USD nên ETH tăng giá hay giảm giá thì token vẫn y hệt và k bị ảnh hưởng bởi bên ngoài
