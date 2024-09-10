const { sendEther, pow } = require("./util");

// Muốn lấy bất cứ contract nào thì require trực tiếp
const IERC20 = artifacts.require("IERC20");
const TestUniswap = artifacts.require("TestUniswap");

contract("TestUniswap", (accounts) => {
    const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
    const WETH_WHALE = "0xc564ee9f21ed8a2d8e7e76c085740d5e4c5fafbe";
    const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const DAI_WHALE = "0xe78388b4ce79068e89bf8aa7f218ef6b9ab0e9d0";

    const CALLER = accounts[0];
    const TOKEN_A = WETH;
    const TOKEN_A_WHALE = WETH_WHALE;
    const TOKEN_B = DAI;
    const TOKEN_B_WHALE = DAI_WHALE;
    const TOKEN_A_AMOUNT = pow(10, 18); // Hàm pow thao tác với BN cũng ảo
    const TOKEN_B_AMOUNT = pow(10, 18);

    let contract;
    let tokenA;
    let tokenB;
    
    // Thay vì gửi từ DAI_WHALE vào accounts[0] thì nếu DAI_WHALE nó éo có ETH thì k gửi được => rất ez ta gửi từ accounts[0] vào DAI_WHALE 1 lượng ETH từ trước để trả fee r mới thực hiện tiếp là đc
    beforeEach(async () => {
        tokenA = await IERC20.at(TOKEN_A);
        tokenB = await IERC20.at(TOKEN_B);
        contract = await TestUniswap.new();

        // send ETH to cover tx fee
        await sendEther(web3, accounts[0], TOKEN_A_WHALE, 1);
        await sendEther(web3, accounts[0], TOKEN_B_WHALE, 1);

        await tokenA.transfer(CALLER, TOKEN_A_AMOUNT, { from: TOKEN_A_WHALE });
        await tokenB.transfer(CALLER, TOKEN_B_AMOUNT, { from: TOKEN_B_WHALE });

        await tokenA.approve(contract.address, TOKEN_A_AMOUNT, { from: CALLER });
        await tokenB.approve(contract.address, TOKEN_B_AMOUNT, { from: CALLER });
    });

    // Ta có thể thấy lượng amount ta nhận ra nó nhỏ hơn amount lúc đầu thực chất là sai vì JS có cơ chế làm tròn số. Thực ra là bằng nhau cả đấy
    it("add liquidity and remove liquidity", async () => {
        let tx = await contract.addLiquidity(
            tokenA.address,
            tokenB.address,
            TOKEN_A_AMOUNT,
            TOKEN_B_AMOUNT,
            {
                from: CALLER, // Thêm object from để cho nó làm msg.sender
            }
        );
        console.log("=== add liquidity ===");
        for (const log of tx.logs) {
            console.log(`${log.args.message} ${log.args.val}`);
        }

        tx = await contract.removeLiquidity(tokenA.address, tokenB.address, {
            from: CALLER,
        });
        console.log("=== remove liquidity ===");
        for (const log of tx.logs) {
        console.log(`${log.args.message} ${log.args.val}`);
        }
    });
});