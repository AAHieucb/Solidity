// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./interfaces/IRouter.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IPair.sol";
import "./interfaces/IWETH.sol";
import "./libraries/TokensUltility.sol";
import "./interfaces/ILPToken.sol";
import "./libraries/LibForRouter.sol"; // quên mất file này r

// Ta k dùng Router kế thừa WETH để gọi hàm trực tiếp được. Ở đây ta dùng contract như 1 người dùng và nó k sở hữu WETH nào cả và sẽ chả bh sở hữu. Nó nhận ETH và đổi sang WETH bằng cách gọi hàm của contract đó và gửi cho pair or trader mà thôi
contract Router is IRouter{
    address factory; // Thay vì truyền vào từng hàm ta lưu biến global + interface dùng mọi luc
    address WETH;
    LibForCounter.data public data;
    event check1(uint amount);
    event checkBalance(string data, uint amount);
    
    // Trước khi gọi hàm này phải deploy 2 contract kia trước
    constructor(address _factory, address _WETH){
        factory = _factory;
        WETH = _WETH;
    }
    
    // Ultilities
    // modifier validAddress(address addr){
    //     require(addr != address(0), "INVALID ADDRESS");
    //     _;
    // }
    // modifier validAmount(uint amount){
    //     require(amount > 0, "INVALID AMOUNT");
    //     _;
    // }
    // modifier ensure(uint deadline){//1800000000
    //     require(deadline >= block.timestamp, "EXPIRED");
    //     _;
    // }
    function checkAmount(uint amount, uint minAMount) internal pure{
        require(amount >= minAMount, "INSUFFICIENT AMOUNT");
    }
    fallback() external payable{
        
    }
    receive() external payable{
        
    }
    
    // addLiquidity
    // Lúc gọi hàm này thì check hết mọi thứ r
    function _addLiquidity(address token1, address token2, uint amount1, uint amount2, address to) internal{
        address pairAddress = IFactory(factory).getAddressOfPairs(token1, token2);
        if(pairAddress == address(0))
            pairAddress = IFactory(factory).createPair(token1, token2);
        IERC20(token1).transferFrom(msg.sender, pairAddress, amount1);
        if(token2 == WETH)
            IWETH(WETH).transfer(pairAddress, amount2);
        else
            IERC20(token2).transferFrom(msg.sender, pairAddress, amount2);
        IPair(pairAddress).addLiquidity(to);
    }

    // :úc gọi hàm này là đã approve cho contract này dùng tưng đó lượng token r
    function addLiquidity(address token1, address token2, uint amount1, uint amount2, address to, uint deadline) 
    external override{
        require(token1 != address(0) && token2 != address(0) && to != address(0) && amount1 > 0 && amount2 > 0 && deadline > block.timestamp,
        "IPARS");
        /*check xem hợp lệ k, check xem sở hữu k
            check xem cặp pair tồn tại k
            tồn tại
                tạo cặp pair mới và add vào
            k tồn tại
                add vào
                    add bằng cách gửi cho pair số token đó
                    cập nhập số dư và gửi lại LP-> gọi hàm add đó
        */
        checkAmount(IERC20(token1).balanceOf(msg.sender), amount1);
        checkAmount(IERC20(token2).balanceOf(msg.sender), amount2);
        _addLiquidity(token1, token2, amount1, amount2, to);
    }
    function addLiquidityWithETH(address token, uint amount, address to, uint deadline) external payable override{
        require(amount > 0 && token != address(0) && to != address(0) && msg.value > 0 && deadline > block.timestamp, "IPARS");
        emit checkBalance("Balance of Router before", address(this).balance);
        checkAmount(IERC20(token).balanceOf(msg.sender), amount);
        IWETH(WETH).swapToWETH{value: msg.value}();
        emit checkBalance("Balance of Router after", address(this).balance);
        emit check1(msg.value);
        _addLiquidity(token, WETH, amount, msg.value, to);
    }
    // Hàm add nó đã cân cả fee-on-transfer token r. Ta nên ưu tiên làm kiểu lấy balance hơn là truyền tham số vì tiện hơn. Hàm remove bth là cái pair nó cũng gửi trực tiếp vào địa chỉ r, nên tự hỗ trợ feeontransfer r. Chỉ cần làm với ETH và permit nx thôi
    //Còn swap thì feeontransfer ta k hỗ trợ hàm đổi ra 1 lượng chính xác fee-on-transfer token vì ta chỉ có 1 cách duy nhất tính lượng token nhận được feeontransfer là lấy cuối trừ đầu mà thôi nên k hỗ trợ. Khi người dùng đổi 1 lượng chính xác fee-on-transfer thì front-end có thể k hiển thị tính năng or chấp nhận hiện thị nhưng đưa ra cảnh báo người nhận sẽ nhận đc 1 lượng ít hơn mong muốn do fee
    // Chính vì cái feeontransfer này mà nên hạn chế hết mức vc truyền tham số vào các hàm 

    // Lúc gọi hàm này phải approve cho contract này dùng 1 lượng LP từ trc r
    function removeLiquidity(address token1, address token2, uint minAmount1, uint minAmount2, uint amount, address to,
    uint deadline) public override{
        require(amount > 0 && to != address(0) && token2 != address(0) && token1 != address(0), "IPARS");
        /*
        Nhận LP token, các thứ hợp lệ, có sở hữu k, cặp pair tồn tại k
        (nếu có lp token của pair này nhưng lại gọi pair khác, nó sẽ k thực hiện vì hàm transferFrom rất chặt, k đủ 
        tiền nó k gửi)
        gửi LP token cho pair
        gọi hàm burn với lượng LP vừa gửi -> nhận về token thì gửi luôn cho trader
        ETH -> gui lai contract de contract gui trader
        */
        require(deadline >= block.timestamp, "EXPIRED");//dùng modifier tốn stack
        uint amount1;
        uint amount2;
        {
            address pairAddress = IFactory(factory).getAddressOfPairs(token1, token2);
            require(pairAddress != address(0), "PAIR NOT FOUND");
            IERC20(pairAddress).transferFrom(msg.sender, pairAddress, amount);
            (amount1, amount2) = IPair(pairAddress).removeLiquidity(to);
        }
        (uint realMinAmount1, uint realMinAmount2) = TokensUltility.sortAmounts(token1, token2, minAmount1, 
                                                                                minAmount2);
        checkAmount(amount1, realMinAmount1);
        checkAmount(amount2, realMinAmount2);
    }
    function _removeLiquidityWithETH(address token, address to, uint amountToken, uint amountETH, uint minAmount, 
    uint minAmountETH) internal{
        checkAmount(amountToken, minAmount);
        checkAmount(amountETH, minAmountETH);
        IERC20(token).transfer(to, amountToken);
        IWETH(WETH).swaptoETH(amountETH);
        (bool success,) = to.call{value: amountETH}("");
        require(success, "FAIL TRANSFER");
        emit check1(amountETH);
    }
    function removeLiquidityWithETH(address token, uint minAmount, uint minAmountETH, uint amount, address to,
    uint deadline) public override{
        // emit checkBalance("Balance of Router before", address(this).balance);
        require(amount > 0 && deadline > block.timestamp && to != address(0) && token != address(0), "IPARS");
        uint amount1;
        uint amount2;
        { // Fix stack too deep error chỉ cho lưu 16 biến ở 1 thời điểm xác định(dùng modifier cũng tốn stack) nên ta tạo amount1 amount2 dùng chung
            address pairAddress = IFactory(factory).getAddressOfPairs(token, WETH);
            require(pairAddress != address(0), "PAIR NOT FOUND");
            IERC20(pairAddress).transferFrom(msg.sender, pairAddress, amount);
            (amount1, amount2) = IPair(pairAddress).removeLiquidity(address(this));
        }
        if(token < WETH){
            _removeLiquidityWithETH(token, to, amount1, amount2, minAmount, minAmountETH);
        }else{
            _removeLiquidityWithETH(token, to, amount2, amount1, minAmount, minAmountETH);
        }
        // emit checkBalance("Balance of Router after", address(this).balance);
    }
    
    function removeLiquidityWithPermit(address token1, address token2, uint minAmount1, uint minAmount2, uint amount, 
    address to, uint deadline, uint8 v, bytes32 r, bytes32 s) external override{
        address pairAddress = IFactory(factory).getAddressOfPairs(token1, token2);
        ILPToken(pairAddress).permit(msg.sender, address(this), amount, deadline, v, r, s);
        removeLiquidity(token1, token2, minAmount1, minAmount2, amount, to, deadline);
    }
    function removeLiquidityETHWithPermit(address token, uint amount, uint minAmountToken, uint minAmountETH, 
    address to, uint deadline, uint8 v, bytes32 r, bytes32 s) external override{
        address pairAddress = IFactory(factory).getAddressOfPairs(token, WETH);
        ILPToken(pairAddress).permit(msg.sender, address(this), amount, deadline, v, r, s);
        removeLiquidityWithETH(token, minAmountToken, minAmountETH, amount, to, deadline);
    }

    function removeLiquiditySupportFeeOnTransferToken(address token1, address token2, uint minAmount1, uint minAmount2, uint amount, 
    address to, uint deadline) public override{
        LibForRouter.removeLiquiditySupportFeeOnTransferToken(data, token1, token2, minAmount1, minAmount2, amount, to, deadline);
    }
    function removeLiquidityWithPermitSupportFeeOnTransferToken(address token1, address token2, uint minAmount1, uint minAmount2, 
    uint amount, address to, uint deadline, uint8 v, bytes32 r, bytes32 s) external override {
        LibForRouter.removeLiquidityWithPermitSupportFeeOnTransferToken(data, token1, token2, minAmount1, minAmount2, amount, to, deadline,
        v, r, s);
    }
    function removeLiquidityETHSupportFeeOnTransferToken(address token, uint minAmount, uint minAmountETH, uint amount, address to,
    uint deadline) public override {
        LibForRouter.removeLiquidityETHSupportFeeOnTransferToken(data, token, minAmount, minAmountETH, amount, to, deadline);
    }
    function removeLiquidityETHWithPermitSupportFeeOnTransferToken(address token, uint amount, uint minAmountToken, uint minAmountETH, 
    address to, uint deadline, uint8 v, bytes32 r, bytes32 s) external override{
        LibForRouter.removeLiquidityETHWithPermitSupportFeeOnTransferToken(data, token, amount, minAmountToken, minAmountETH, to, deadline,
        v, r, s);
    }
    
    // Path chắc chắn dẫn đúng các pool đã có
    // Check hết r. Hàm này swap vào địa chỉ của contract này 1 lượng nhận được sau swap
    // Lúc gọi hàm này thì path[0] đã được gửi vào 1 lượng amount r
    function _swap(uint amount, address[] calldata path) internal{
        // Check mọi thứ đầy đủ và hợp lệ
        // Gửi token cho pair tiếp theo
        // Duyệt các pair và gửi cho pair tiếp theo luôn, chỉ vòng cuối mới gửi lại đây
        address pairAddress = IFactory(factory).getAddressOfPairs(path[0], path[1]);
        uint currentAmount = amount;
        for(uint i = 1; i < path.length - 1; i++){
            address nextPairAddress = IFactory(factory).getAddressOfPairs(path[i], path[i + 1]);
            // Vì trong pair sắp xếp sẵn r nên ta phải xd truyền vào cái nào
            if(path[i - 1] < path[i])
                currentAmount = IPair(pairAddress).swap(nextPairAddress, currentAmount, 0);
            else
                currentAmount = IPair(pairAddress).swap(nextPairAddress, 0, currentAmount);
            pairAddress = nextPairAddress;
        }
        if(path[path.length - 1] > path[path.length - 2])
            IPair(pairAddress).swap(address(this), currentAmount, 0);
        else
            IPair(pairAddress).swap(address(this), 0, currentAmount);
    }

    // Lúc gọi hàm đã approve cho Router dùng 1 lượng amount r.
    function swapExactTokenForToken(uint amount, address to, uint minAmount2, address[] calldata path, uint deadline)
    external override{
        require(amount > 0 && to != address(0) && deadline > block.timestamp, "IPARS");
        /*
        Check mọi thứ hợp lệ
        Duyệt từng path và truyền vào lần lượt các pool. Các pool xử lý luôn
        Kết quả trả ra sẽ truyền cho pool tiếp theo or end r thì truyền về contract này
        Contract này check đủ amount thì kết thúc. K đủ thì revert
        */
        /*
        uint currentAmount = amount;
        IERC20(token1).transferFrom(msg.sender, address(this), amount);
        for(uint i = 0; i < path.length - 1; i++){
            address pairAddress = IFactory(factory).getAddressOfPairs(path[i], path[i + 1]);
            require(pairAddress != address(0), "PAIR NOT FOUND");
            IERC20(path[i]).transfer(pairAddress, currentAmount);
            if(i + 1 != path.length - 1)
                if(path[i] < path[i + 1])
                    currentAmount = IPair(pairAddress).swap(address(this), currentAmount, 0);
                else
                    currentAmount = IPair(pairAddress).swap(address(this), 0, currentAmount);
            else
                currentAmount = IPair(pairAddress).swap(address(this), currentAmount, 0);
            // Lấy pairadress
            // Gửi token vào pair address lượng lưu ở vòng trước
            // Gọi hàm swap nhận ra 1 lượng token mới lưu lại
            // Gọi hàm swap và lấy đầu ra lưu token vòng này
                // gửi vào contract tiếp or gửi vào contract này
        }*/
        address pairAddress = IFactory(factory).getAddressOfPairs(path[0], path[1]);
        IERC20(path[0]).transferFrom(msg.sender, pairAddress, amount);
        _swap(amount, path);
        uint currentAmount = IERC20(path[path.length - 1]).balanceOf(address(this));
        // Đến đây là contract này đã có ok r, gửi lại cho trader thôi
        checkAmount(currentAmount, minAmount2);
        // emit check1(currentAmount);
        // if(currentAmount != 0)
        IERC20(path[path.length - 1]).transfer(to, currentAmount);
        // else
        //     IERC20(path[path.length - 1]).transfer(to, currentAmount2);
    }
    function swapExactTokenForETH(uint amount, address to, uint minAmountETH, address[] calldata path, uint deadline) 
    external override{
        require(amount > 0 && to != address(0) && deadline > block.timestamp, "IPARS");
        address pairAddress = IFactory(factory).getAddressOfPairs(path[0], path[1]);
        IERC20(path[0]).transferFrom(msg.sender, pairAddress, amount);
        _swap(amount, path);
        uint currentAmount = IERC20(WETH).balanceOf(address(this));
        checkAmount(currentAmount, minAmountETH);
        IWETH(WETH).swaptoETH(currentAmount);
        (bool success,) = to.call{value: currentAmount}("");
        require(success, "FAIL TRANSFER ETH");
    }
    function swapExactETHForToken(address to, uint minAmountToken, address[] calldata path, uint deadline) 
    payable external override returns(uint){//v
        require(msg.value > 0 && to != address(0) && deadline > block.timestamp, "IPARS");
        IWETH(WETH).swapToWETH{value: msg.value}();
        address pairAddress = IFactory(factory).getAddressOfPairs(path[0], path[1]);
        IWETH(WETH).transfer(pairAddress, msg.value);
        _swap(msg.value, path);
        uint currentAmount = IERC20(path[path.length - 1]).balanceOf(address(this));
        checkAmount(currentAmount, minAmountToken);
        IERC20(path[path.length - 1]).transfer(to, currentAmount);
        return currentAmount;
    }

    // Trước khi gọi hàm này thì phải approve cho contract sử dụng amountInMax r
    // Thật ra khi user swap như dưới thì front end phải lấy amount và xử lý hiện ra cho người dùng cần deposit vào bnh r nên chắc chắn bên dưới thỏa mãn. Nhưng khi làm contract này public thì ai cx gọi được nên mặc kệ front-end
    // Có xử lý hay k thì ở đây ta vẫn phải xử lý đầy đủ. Front end nên hiện lệch 1,2 wei để chắc chắn
    function swapTokenForExactToken(uint amountInMax, uint amountOut, address to, address[] calldata path, 
    uint deadline) external override{
        require(amountInMax > 0 && amountOut > 0 && to != address(0) && deadline > block.timestamp, "IPARS");
        // Tính ngược lại amountInMax từ amountOut nếu hợp lệ thì thực hiện swap
        uint amountIn = TokensUltility.getAmountsIn(amountOut, path, factory);
        // Hàm này phải tính được lượng amountIn để nhận được đúng lượng amountOut or nhiều hơn 1 tí cx đc chứ k đc ít hơn
        checkAmount(amountInMax, amountIn);
        address pairAddress = IFactory(factory).getAddressOfPairs(path[0], path[1]);
        IERC20(path[0]).transferFrom(msg.sender, pairAddress, amountIn);
        _swap(amountIn, path);
        IERC20(path[path.length - 1]).transfer(to, IERC20(path[path.length - 1]).balanceOf(address(this)));
    }
    function swapTokenForExactETH(uint amountInMax, uint amountOut, address to, address[] calldata path, uint deadline)
    external override{
        require(amountOut > 0 && to != address(0) && deadline > block.timestamp, "IPARS");
        uint amountIn = TokensUltility.getAmountsIn(amountOut, path, factory);
        checkAmount(amountInMax, amountIn);
        address pairAddress = IFactory(factory).getAddressOfPairs(path[0], path[1]);
        IERC20(path[0]).transferFrom(msg.sender, pairAddress, amountIn);
        _swap(amountIn, path);
        uint currentAmount = IWETH(WETH).balanceOf(address(this));
        IWETH(WETH).swaptoETH(currentAmount);
        (bool success,) = to.call{value: currentAmount}("");
        require(success, "FAIL TRANSFER ETH");
    }
    // Lúc gọi hàm này thì gửi vào trong contract 1 lượng max
    function swapETHForExactToken(uint amountOut, address to, address[] calldata path, uint deadline) 
    external payable override{//v
        require(amountOut > 0 && msg.value > 0 && to != address(0) && deadline > block.timestamp, "IPARS");
        // Check hợp lệ
        uint amountIn = TokensUltility.getAmountsIn(amountOut, path, factory);
        // Lấy lượng đầu ra
        checkAmount(msg.value, amountIn);
        // Lượng đầu ra phải đủ mong muốn của trader
        IWETH(WETH).swapToWETH{value: amountIn}();
        // Đổi sang WETH
        address pairAddress = IFactory(factory).getAddressOfPairs(path[0], path[1]);
        IWETH(WETH).transfer(pairAddress, amountIn);
        _swap(amountIn, path);
        uint currentAmount = IERC20(path[path.length - 1]).balanceOf(address(this));
        // Gửi WETH vào cặp pairs đầu tiên và thực hiện swap
        IERC20(path[path.length - 1]).transfer(to, currentAmount);
        // Gửi lượng token nhận được cho trader
        if(msg.value > amountIn) {
            (bool success,) = msg.sender.call{value: msg.value - amountIn}("");
            require(success, "FAIL TRANSFER");
            // Trả lại tiền thừa
        }
    }

    function swapExactTokenForTokenSupportFeeOnTransferToken(uint amount, address to, uint minAmount2, address[] calldata path, 
    uint deadline) external override{
        LibForRouter.swapExactTokenForTokenSupportFeeOnTransferToken(data, amount, to, minAmount2, path, deadline);
    }
    function swapExactTokenForETHSupportFeeOnTransferToken(uint amount, address to, uint minAmountETH, address[] calldata path, uint deadline) 
    external override{
        LibForRouter.swapExactTokenForETHSupportFeeOnTransferToken(data, amount, to, minAmountETH, path, deadline);
    }
    function swapExactETHForTokenSupportFeeOnTransferToken(address to, uint minAmountToken, address[] calldata path, uint deadline) 
    payable external override{
        LibForRouter.swapExactETHForTokenSupportFeeOnTransferToken(data, to, minAmountToken, path, deadline);
    }
}
