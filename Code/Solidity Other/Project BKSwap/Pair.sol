// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./interfaces/IPair.sol";
import "./supportcontracts/LPToken.sol";
import "./interfaces/IFactory.sol";
import "./otherlibs/Math.sol";
import "./interfaces/IERC20.sol";

// Contract này chính là 1 ERC20 là LP token luôn. Vì ta muốn toàn quyền sử dụng 1 LP token riêng
contract Pair is IPair, LPToken{
    event check(uint amount, uint amount1);
    address public token1;
    address public token2;
    address public factory;
    uint public override reserve1;
    uint public override reserve2;
    uint feeParams = 0;
    
    // Token đã được sắp xếp trước khi vào đây
    constructor(address _token1, address _token2){
        token1 = _token1;
        token2 = _token2;
        factory = msg.sender;
    }
    
    function mintFeeForDev() public override {
        // Check xem có swap để mint chưa
        // Nếu có
            // Tính toan và tăng cho dev
        uint tempFeeParams = reserve1*reserve2;
        if(tempFeeParams > feeParams){
            uint sqrt1 = Math.sqrt(tempFeeParams);
            uint sqrt2 = Math.sqrt(feeParams);
            uint amountOfLPToken = totalSupply()*(sqrt1 - sqrt2)/(29*sqrt2 + sqrt1);
            mintTo(IFactory(factory).addrReceiveFee(), amountOfLPToken);
        }
    }
    function _addLiquidity(uint addingAmount1, uint addingAmount2, address to) internal returns(uint){
        /*nếu lần add đầu tiên
            thêm thanh khoản vào lần đầu
                cập nhập số dư của 2 cái đó
                đào LP token và gửi cho người add
        các lần add sau
            mint fee cho nhà phát triển
            thêm thanh khoản vào
                cập nhập số dư của 2 cái đó
                đào LP token và gửi cho người add
        */
        uint amountOfLPToken = 0;
        if(totalSupply() != 0){
            uint rateNow = reserve1/reserve2;
            uint addingRate = addingAmount1/addingAmount2;
            if(addingRate > rateNow){
                amountOfLPToken  = addingAmount2*totalSupply()/reserve2;
            }else{
                amountOfLPToken = addingAmount1*totalSupply()/reserve1;
            }
        }
        else{
            amountOfLPToken = Math.sqrt(addingAmount1*addingAmount2);
        }
        // reserve1 += addingAmount1;
        // reserve2 += addingAmount2;
        // Hàm này ai cũng gọi được nên 1 thg bất kỳ có thể vào contract và điền bừa addingAmount dù chưa gửi gì cả nguy hiểm các hàm public ai cũng gọi được nên lấy số dư như này cho chuẩn
        reserve1 = IERC20(token1).balanceOf(address(this));
        reserve2 = IERC20(token2).balanceOf(address(this));
        mintTo(to, amountOfLPToken);
        // emit check(amountOfLPToken,0);
        return amountOfLPToken;
    }
    // Khi gọi addLiquidity là addingAmount1, addingAmount2 đã sắp xếp đúng thứ tự, đã gửi token vào pair này r địa chỉ to cx hợp lệ r, 2 lượng tiền check hợp lệ hết r
    // Dùng external tức là 1 thg khác cx có thể vào và addLiquidity cho nó thì addingAmount sẽ = 0 thì addingRate có phép chia mẫu số là 0 sẽ báo error
    function addLiquidity(address to) external override returns(uint){
        if(feeParams != 0){
            mintFeeForDev();
        }
        // Các contract được xử lý với tốc độ rất cao như C++ v và nó thực hiện đồng bộ nên k sợ 1 người chuyển vào cập nhập số dư xong 1 ông khác cũng chuyển vào thì số dư bị lỗi -> nó đồng bộ theo thứ tự hết
        uint addingAmount1 = IERC20(token1).balanceOf(address(this)) - reserve1;
        uint addingAmount2 = IERC20(token2).balanceOf(address(this)) - reserve2;
        uint amountOfLPToken = _addLiquidity(addingAmount1, addingAmount2, to);
        feeParams = reserve1*reserve2;
        return amountOfLPToken;
    }
    function removeLiquidity(address to) external override returns(uint, uint){
        // Nhận vào lượng LP token và tính ra phần gửi lại cho trader. Người ta gọi được hàm remove thì chắc chắn đã từng add trước đó r. Nhận vào amount Lp token, address của nơi cần gửi tới
        /*mintFeeForDev
        tính lượng token gửi vào address, update reserve
        gán lại feeParams
        */
        mintFeeForDev();
        uint amount = balanceOf(address(this));
        uint amount1 = amount*reserve1/totalSupply();
        uint amount2 = amount*reserve2/totalSupply();
        IERC20(token1).transfer(to, amount1);
        IERC20(token2).transfer(to, amount2);
        burnToken(amount);
        // emit check(balanceOf(address(this)),amount);
        reserve1 -= amount1;
        reserve2 -= amount2;
        feeParams = reserve1*reserve2;
        return (amount1, amount2);
    }
    // Lúc gọi swap là mọi thứ đã check hết r. Token đã được gửi vào pool này r. Pool này chỉ cần gửi đi tiếp thôi
    function swap(address to, uint amount1, uint amount2) external override returns(uint){
        // Nó nhận địa chỉ và lượng token đã nhận thêm
            // Tính amount và update số dư
                // Gửi cho địa chỉ to
        require(reserve1 > 0 && reserve2 > 0, "POOL EMPTY");
        require(reserve1 + amount1 == IERC20(token1).balanceOf(address(this)) && 
                reserve2 + amount2 == IERC20(token2).balanceOf(address(this)), "SEND TOKEN TO ME FIRST");
        // Vì hàm này ai cũng gọi được nên đk check bên trên sẽ xử lý user phải truyền token vào cho nó
        uint sendAmount2 = reserve2 - reserve1*reserve2*1000/(reserve1*1000 + amount1*997);
        uint sendAmount1;
        if(sendAmount2 <= 0){
            sendAmount1 = reserve1 - reserve1*reserve2*1000/(reserve2*1000 + amount2*997);
            IERC20(token1).transfer(to, sendAmount1);
        }
        IERC20(token2).transfer(to, sendAmount2);
        reserve1 = IERC20(token1).balanceOf(address(this));
        reserve2 = IERC20(token2).balanceOf(address(this));
        emit check(amount1, amount2);
        emit check(sendAmount1, sendAmount2);
        return sendAmount2 <= 0 ? sendAmount1 : sendAmount2; // Trả ra khoản tiền nhận được
    }

    // Để bảo contract này gửi token cho ta từ 1 hàm của chính nó. Ta k thể dùng transferFrom hay transfer được vì 1 cái đòi approve, 1 cái gửi từ msg.sender => cái ta cần là gửi từ contract này tức là contract này phải là thứ gọi bằng call thì msg.sender sẽ là contract này và gửi vào địa chỉ nào
    function smartTransfer(address token, address to, uint amount) internal {
        (bool success, ) = token.call(
            abi.encodeWithSignature("transfer(address,uint256)", to, amount)
        );
        require(success, "FAIL TRANSFER");
    }
    // 2 hàm dưới nên là kbh bị gọi nếu mọi thứ ta xử lý đều chuẩn
    function skim(address to) external {
        address _token1 = token1; 
        address _token2 = token2;
        smartTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)) - reserve1);
        smartTransfer(_token2, to, IERC20(_token2).balanceOf(address(this)) - reserve2);
    }
    function sync() external {
        reserve1 = IERC20(token1).balanceOf(address(this));
        reserve2 = IERC20(token2).balanceOf(address(this));
    }
}
