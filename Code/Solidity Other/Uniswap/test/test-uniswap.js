const BN = require("bn.js");
const { sendEther } = require("./util");

const IERC20 = artifacts.require("IERC20");
const TestUniswap = artifacts.require("TestUniswap");

contract("TestUniswap", (accounts) => {
    const WBTC_WHALE = "0xe78388b4ce79068e89bf8aa7f218ef6b9ab0e9d0";
    const AMOUNT_IN = 100000000;
    const AMOUNT_OUT_MIN = 1;
    const TOKEN_IN = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599";
    const TOKEN_OUT = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const TO = accounts[0];

    let testUniswap;
    let tokenIn;
    let tokenOut;
    beforeEach(async () => {
        tokenIn = await IERC20.at(TOKEN_IN);
        tokenOut = await IERC20.at(TOKEN_OUT);
        testUniswap = await TestUniswap.new();
        await sendEther(web3, accounts[0], WBTC_WHALE, 1);
        console.log("Balance: " + await web3.eth.getBalance(WBTC_WHALE));
        await tokenIn.approve(testUniswap.address, AMOUNT_IN, { from: WBTC_WHALE });
    });

    it("should pass", async () => {
        await testUniswap.swap(
        tokenIn.address,
        tokenOut.address,
        AMOUNT_IN,
        AMOUNT_OUT_MIN,
        TO,
        {
            from: WBTC_WHALE,
        }
        );

        console.log(`in ${AMOUNT_IN}`);
        console.log(`out ${await tokenOut.balanceOf(TO)}`);
    });
});
