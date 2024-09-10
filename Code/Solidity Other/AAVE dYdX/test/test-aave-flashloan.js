// # AAVE dYdX

const BN = require("bn.js")
const { sendEther, pow } = require("./util")

const IERC20 = artifacts.require("IERC20")
const TestAaveFlashLoan = artifacts.require("TestAaveFlashLoan")

contract("TestAaveFlashLoan", (accounts) => {
  const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"
  const USDC_WHALE = "0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE"
  const WHALE = USDC_WHALE
  const TOKEN_BORROW = USDC
  const DECIMALS = 6
  const FUND_AMOUNT = pow(10, DECIMALS).mul(new BN(2000))
  const BORROW_AMOUNT = pow(10, DECIMALS).mul(new BN(1000))

  const ADDRESS_PROVIDER = "0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5"

  let testAaveFlashLoan
  let token
  beforeEach(async () => {
    token = await IERC20.at(TOKEN_BORROW)
    // Khởi tạo constructor cho nó. Ở đây ta sẽ vay USDC
    testAaveFlashLoan = await TestAaveFlashLoan.new(ADDRESS_PROVIDER)

    // Gửi ether vào USDC_WHALE để trả được phí giao dịch
    await sendEther(web3, accounts[0], WHALE, 1)

    // Gửi USDC vào cái contract kia để nó trả được premiums fee
    const bal = await token.balanceOf(WHALE)
    assert(bal.gte(FUND_AMOUNT), "balance < FUND")
    await token.transfer(testAaveFlashLoan.address, FUND_AMOUNT, {
      from: WHALE,
    })
  })

  it("flash loan", async () => {
    // Thực hiện vay
    const tx = await testAaveFlashLoan.testFlashLoan(token.address, BORROW_AMOUNT, {
      from: WHALE,
    })
    // Lấy ra event
    for (const log of tx.logs) {
      console.log(log.args.message, log.args.val.toString())
    }
  })
})

// Fork mainnet bằng ganache unlock account của USDC_WHALE thông qua url infura mainnet và networkId set cho giá trị ta mong muốn, set cái mainnet fork này trong config truffle -> chạy truffle test trên mainnet fork đó
// Kết quả ta lấy phụ thuộc vào decimals của các đồng như nào, vì USDC chỉ có 6 decimals nên chia 10^6 ở kết quả mới ra giá trị thực tế nhận