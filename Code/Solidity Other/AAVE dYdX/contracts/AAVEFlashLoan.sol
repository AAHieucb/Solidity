// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/aave/FlashLoanReceiverBase.sol";

contract TestAaveFlashLoan is FlashLoanReceiverBase {
    using SafeMath for uint;

    event Log(string message, uint val);

    // Để chạy phải khởi tạo địa chỉ LendingPoolAddressesProvider cho nó
    constructor(
        ILendingPoolAddressesProvider _addressProvider
    ) public FlashLoanReceiverBase(_addressProvider) {}

    function testFlashLoan(address asset, uint amount) external {
        // Check contract có đủ khoản tiền ta muốn vay
        uint bal = IERC20(asset).balanceOf(address(this));
        require(bal > amount, "bal <= amount");

        address receiver = address(this);

        address[] memory assets = new address[](1);
        assets[0] = asset;

        uint[] memory amounts = new uint[](1);
        amounts[0] = amount;

        // 0 = no debt - pay all loaned, 1 = stable, 2 = variable
        uint[] memory modes = new uint[](1);
        modes[0] = 0;

        address onBehalfOf = address(this);

        bytes memory params = ""; // extra data to pass abi.encode(...)
        uint16 referralCode = 0;

        // Các tham số: receiver là contract nhận được khoản vay
        // assets là vay những loại tài sản nào
        // amounts là số lượng từng loại tài sản muốn vay
        // mode có 3 mode như trên
        // onBehalfOf là address nhận khoản nợ nếu modes chọn là 1 or 2
        // params arg truyền vào executeOperation
        // referralCode cứ set là 0
        // Khi gọi hàm này thì nó sẽ gửi cho ta lượng tài sản ta vay và gọi vào hàm executeOperation bên dưới. Trong hàm đó xử lý gì tùy ý nhưng ở cuối hàm phải trả lại khoản tiền đã vay + 1 lượng phí
        LENDING_POOL.flashLoan(
            receiver,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }

    // Assets là tài sản vay, amounts là lượng đã borrow và nhận được rồi, premiums là lượng phí từng tương ứng với từng token ta vay và h phải trả, initiator là address đã gọi hàm flashLoan bên trên, params là params của flashLoan từ hàm trên
    function executeOperation(
        address[] calldata assets,
        uint[] calldata amounts,
        uint[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        // do stuff here (arbitrage, liquidation, etc...)
        // abi.decode(params) to decode params
        // Ở đây ta đơn giản in ra lượng borrow và lượng fee cần trả xong trả lai thôi
        // Chú ý ta không cần transfer mà chỉ cần approve cho Lendingpool của AAVE nhận lượng token r nó tự gọi ngay sau hàm executeOperation kết thúc
        for (uint i = 0; i < assets.length; i++) {
            emit Log("borrowed", amounts[i]);
            emit Log("fee", premiums[i]);

            uint amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
        }
        // tự repay Aave
        return true;
    }
}
