// # Tương tác Uniswap

const IERC20 = artifacts.require("IERC20");
// Để tương tác với contract ta cần ít nhất là interface thì mới gọi được

contract("IERC20", accounts => {{
    // Ta unlock accoutn DAI_WHALE để sử dụng chứa rất nhiều DAI
    const DAI = "0x6b175474e89094c44da98b954eedeac495271d0f";
    const DAI_WHALE = "0xe78388b4ce79068e89bf8aa7f218ef6b9ab0e9d0";
    it("get DAI balance", async () => {
        const dai = await IERC20.at(DAI);
        const bal = await dai.balanceOf(DAI_WHALE);
        console.log(`bal: ${bal}`);
        // Dùng `` kiểu này in ra balance tự rút gọn chỉ còn 1 số luôn còn dùng ("bal:",bal) sẽ ra object BN
    })
    it("should transfer", async () => {
        const dai = await IERC20.at(DAI);
        const bal = await dai.balanceOf(DAI_WHALE);
        await dai.transfer(accounts[0], bal, {from: DAI_WHALE});
        // Ganache vẫn có các account mặc định trong param accounts. Ta dùng được account DAI_WHALE đã unlock
    })
}})