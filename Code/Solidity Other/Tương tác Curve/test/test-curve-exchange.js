// # Tương tác Curve

const BN = require("bn.js")
const { sendEther, pow } = require("./util")

const IERC20 = artifacts.require("IERC20")
const TestCurveExchange = artifacts.require("TestCurveExchange")

contract("TestCurveExchange", (accounts) => {
    const USDC_WHALE = "0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE";
    const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    const USDT = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
  const WHALE = USDC_WHALE
  const TOKEN_IN = USDC
  const TOKEN_IN_INDEX = 1
  const TOKEN_OUT = USDT
  const TOKEN_OUT_INDEX = 2
  const DECIMALS = 6
  const TOKEN_IN_AMOUNT = pow(10, DECIMALS).mul(new BN(10000))
//   mục đích ta sẽ send 10000 USDC và log ra lượng USDT nhận được

  let testContract
  let tokenIn
  let tokenOut
  beforeEach(async () => {
    tokenIn = await IERC20.at(TOKEN_IN)
    tokenOut = await IERC20.at(TOKEN_OUT)
    testContract = await TestCurveExchange.new()

    await sendEther(web3, accounts[0], WHALE, 1)

    const bal = await tokenIn.balanceOf(WHALE)
    assert(bal.gte(TOKEN_IN_AMOUNT), "balance < TOKEN_IN_AMOUNT")

    await tokenIn.transfer(testContract.address, TOKEN_IN_AMOUNT, {
      from: WHALE,
    })
  })

  it("exchange", async () => {
    const snapshot = async () => {
      return {
        tokenOut: await tokenOut.balanceOf(testContract.address),
      }
    }

    // const before = await snapshot()
    await testContract.swap(TOKEN_IN_INDEX, TOKEN_OUT_INDEX)
    const after = await snapshot()

    console.log(`Token out: ${after.tokenOut}`)
    // ta thấy nó không xấp xỉ bằng nhau vì nó tự loại 0 ở cuối, thực ra số tiền ta nhận được là 999.. là
    //xấp xỉ 10000 bên trên
  })
})