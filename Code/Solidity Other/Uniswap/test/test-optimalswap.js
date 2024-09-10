const BN = require("bn.js")
const { sendEther, pow } = require("./util")
const { WETH, DAI, DAI_WHALE } = require("./config")

const IERC20 = artifacts.require("IERC20")
const TestUniswapOptimal = artifacts.require("TestUniswapOptimal")

contract("TestUniswapOptimal", (accounts) => {
    const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
    const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F"
    const DAI_WHALE = "0xF977814e90dA44bFA03b6295A0616a897441aceC"
    const WHALE = DAI_WHALE
    const AMOUNT = pow(10, 18).mul(new BN(1000))

    let contract
    let fromToken
    let toToken
    let pair
    beforeEach(async () => {
        fromToken = await IERC20.at(DAI)
        toToken = await IERC20.at(WETH)
        contract = await TestUniswapOptimal.new()
        pair = await IERC20.at(await contract.getPair(fromToken.address, toToken.address))

        await sendEther(web3, accounts[0], WHALE, 1)
        fromToken.approve(contract.address, AMOUNT, { from: WHALE })
    })

    const snapshot = async () => {
        return {
            lp: await pair.balanceOf(contract.address),
            fromToken: await fromToken.balanceOf(contract.address),
            toToken: await toToken.balanceOf(contract.address),
        }
    }

    // Test hàm swap optimal
    it("optimal swap", async () => {
        // const before = await snapshot()
        await contract.zap(fromToken.address, toToken.address, AMOUNT, {
            from: WHALE,
        })
        const after = await snapshot()

        // Sau khi swap xong ta check lại balance nếu 0 hết cả
        console.log("lp", after.lp.toString())
        console.log("from", after.fromToken.toString())
        console.log("to", after.toToken.toString())
        /*
        lp 93117251647135739454170
        from 2 
        to 0 => cả from và to là khoản token trong tk này đều là 0 vì tất cả đều đã addLiquidity one-side
        */
    })

    // // test hàm swap mà lấy 1 nửa -> k optimal
    // it("sub-optimal swap", async () => {
    //     // const before = await snapshot()
    //     await contract.subOptimalZap(fromToken.address, toToken.address, AMOUNT, {
    //         from: WHALE,
    //     })
    //     const after = await snapshot()
    //     console.log("lp", after.lp.toString())
    //     console.log("from", after.fromToken.toString())
    //     console.log("to", after.toToken.toString())
    //     /*
    //     lp 91461240284427443354176
    //     from 0
    //     to 86904179339298595766169
    //     */
    // })
})