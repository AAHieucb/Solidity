const BN = require("bn.js")
const { sendEther, pow } = require("./util")

const IERC20 = artifacts.require("IERC20")
const TestUniswapFlashSwap = artifacts.require("TestUniswapFlashSwap")

contract("TestUniswapFlashSwap", (accounts) => {
    const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    const USDC_WHALE = "0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE";
    const WHALE = USDC_WHALE
    const TOKEN_BORROW = USDC
    const DECIMALS = 6
    const FUND_AMOUNT = pow(10, DECIMALS).mul(new BN(2000000))
    const BORROW_AMOUNT = pow(10, DECIMALS).mul(new BN(1000000))

    let testUniswapFlashSwap
    let token
    beforeEach(async () => {
        token = await IERC20.at(TOKEN_BORROW)
        testUniswapFlashSwap = await TestUniswapFlashSwap.new()
        await sendEther(web3, accounts[0], WHALE, 1)
        // send enough token to cover fee => cái WHALE đã có đủ ETH trả fee

        const bal = await token.balanceOf(WHALE)
        assert(bal.gte(FUND_AMOUNT), "balance < FUND") 
        // Check nếu số dư USDC của WHALE >= FUND_AMOUNT thì transfer nó sang địa chỉ contract flash swap vì thực chất ta muốn flashswap vay thử 1 lượng BORROW_AMOUNT nhưng thực tế cuối contract ta phải trả lại 1 lượng lớn hơn là BORROW_AMOUNT + 0.3%BORROW_AMOUNT là fee đó nên tốt nhất cứ truyền hẳn cho contract 1 lượng USDC là FUND_AMOUNT gấp đôi luôn để thực hiện ok. Cần unlock USDC_WHALE
        await token.transfer(testUniswapFlashSwap.address, FUND_AMOUNT, {
            from: WHALE,
        })
    })

    it("flash swap", async () => {
        const tx = await testUniswapFlashSwap.testFlashSwap(token.address, BORROW_AMOUNT, {
            from: WHALE,
        })
        for (const log of tx.logs) {
            console.log(log.args.message, log.args.val.toString())//lấy log
        }
    })
})