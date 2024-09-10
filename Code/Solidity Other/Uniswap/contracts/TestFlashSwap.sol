// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./IERC20.sol";
import "./IUniswap.sol";

interface IUniswapV2Callee {
    function uniswapV2Call(
        // Hàm được gọi khi dùng dùng flashswap
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;
}

contract TestUniswapFlashSwap is IUniswapV2Callee {
    // Uniswap V2 router
    // 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // Uniswap V2 factory
    address private constant FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    event Log(string message, uint val);

    function testFlashSwap(address _tokenBorrow, uint _amount) external {
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenBorrow, WETH);
        require(pair != address(0), "!pair"); // cCặp pair tồn tại
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        uint amount0Out = _tokenBorrow == token0 ? _amount : 0;
        uint amount1Out = _tokenBorrow == token1 ? _amount : 0;

        // need to pass some data to trigger uniswapV2Call. Nó là token nào muốn vay nhanh và số lượng token đó
        bytes memory data = abi.encode(_tokenBorrow, _amount);
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
        // Trong uniswap để gọi flash swap thì hàm swap của cặp pair người ta có dùng đối số thứ 4 là bytes chỉ hàm cần gọi khi thực hiện flashswap. Nếu k dùng đối số 4 tức là dùng regular swap. Nếu truyền hàm đối số thứ 4 là non-empty thì sẽ trigger flash swap.
        // Ta k gọi router mà gọi hàm trực tiếp từ Pair
    }

    // Cơ chế: trong hàm swap của pair nó sẽ check nếu đối số 4 data truyền vào khác rỗng thì nó sẽ gọi hàm của IUniswapV2Callee thông qua interface lấy địa chỉ chính là đối số 3. Tức hàm call đó ta định nghĩa trong contract này luôn để pair gọi đến nó khi execute. Cụ thể vào hàm swap của pair: nó check các thứ r gửi cho address(to) lượng token còn lại mà ta muốn swap ra -> sau đó nó gọi callee nếu data!=0 -> bên trong callee ta dùng lượng token kia để làm gì đó và sau đó phải trả lại lượng token đó cho pair -> sau đó pair sẽ check mọi thứ như có trả lại đủ token sau khi flash swap hay k. Điều này có thể thực hiện dễ dàng bằng cách check balance rằng nếu tự nhiên K bị giảm đi vì 1 lượng token gửi cho người khác xong k nhận lại gì cả làm k giảm thì hoàn tác ez

    // called by pair contract
    function uniswapV2Call(
        address _sender,
        uint _amount0,
        uint _amount1,
        bytes calldata _data
    ) external override {
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        address pair = IUniswapV2Factory(FACTORY).getPair(token0, token1);
        require(msg.sender == pair, "!pair");
        require(_sender == address(this), "!sender");
        (address tokenBorrow, uint amount) = abi.decode(_data, (address, uint));
        // Phải decode để lấy các tham số đã truyền

        // about 0.3%
        uint fee = ((amount * 3) / 997) + 1;
        uint amountToRepay = amount + fee;

        // do stuff here
        // Hiện tại thì contract này đã được pair gửi cho amount lượng tokenBorrow rồi. Ta có thể làm gì đó ở đây như đem đi đầu tư ở chỗ khác => rất ez lấy interface và address của contract để gọi mượt
        emit Log("amount", amount);
        emit Log("amount0", _amount0);
        emit Log("amount1", _amount1);
        emit Log("fee", fee);
        emit Log("amount to repay", amountToRepay);
        IERC20(tokenBorrow).transfer(pair, amountToRepay);
        // Làm gì đó xong phải trả lại cho pair lượng token ban đầu cộng với khoản phí trực tiếp
    }
}
