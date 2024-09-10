const {
    expect
} = require("chai");

// const {
//     ethers
// } = require("hardhat");

// Code chai và ethersjs để deploy trong môi trường kiểm thử và viết test case
describe("Token contract", function () {
    // Mocha has four functions that let you hook into the the test runner's
    // lifecyle. These are: `before`, `beforeEach`, `after`, `afterEach`.

    // They're very useful to setup the environment for tests, and to clean it
    // up after they run.

    // A common pattern is to declare some variables, and assign them in the
    // `before` and `beforeEach` callbacks.

    let Token;
    let hardhatToken;
    let owner;
    let addr1;
    let addr2;
    let addrs;

    // `beforeEach` will run before each test, re-deploying the contract everytime. 
    // It receives a callback, which can be async.
    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        Token = await ethers.getContractFactory("Token");
        // ContractFactory là abstraction deploy smart contract. Token ở đây là factory for instance of contract của ta
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        // Singer là object trong ethers.js lấy Ethereum account. Nó thg dùng để send trans cho contract và other accounts. Ở đây ta lấy về 1 list account đang connect vào

        // To deploy our contract, we just have to call Token.deploy() and await
        // for it to be deployed(), which happens once its transaction has been
        // mined.
        hardhatToken = await Token.deploy(); // Deploy cái instance đó, nó tự động dùng account đầu tiên nhé
    });

    // You can nest describe calls to create subsections.
    describe("Deployment", function () {
        // `it` is another Mocha function. This is the one you use to define your
        // tests. It receives the test name, and a callback function.

        // If the callback function is async, Mocha will `await` it.
        it("Should set the right owner", async function () {
            // Expect receives a value, and wraps it in an Assertion object. These
            // objects have a lot of utility methods to assert values.

            // This test expects the owner variable stored in the contract to be equal
            // to our Signer's owner.
            expect(await hardhatToken.owner()).to.equal(owner.address); // Code waffle(waffle cũng có Chai assertion)
            // Do mặc định contract instance được kết nối với first signer nên khi deploy thì first signer gọi constructor
        });

        it("Should assign the total supply of tokens to the owner", async function () {
            const ownerBalance = await hardhatToken.balanceOf(owner.address);
            expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
        });
    });

    describe("Transactions", function () {
        it("Should transfer tokens between accounts", async function () {
            // Transfer 50 tokens from owner to addr1
            await hardhatToken.transfer(addr1.address, 50);
            const addr1Balance = await hardhatToken.balanceOf(addr1.address);
            expect(addr1Balance).to.equal(50);

            // Transfer 50 tokens from addr1 to addr2
            // We use .connect(signer) to send a transaction from another account
            // Nếu k mặc định nó gọi hàm bằng address của deployer
            await hardhatToken.connect(addr1).transfer(addr2.address, 50);
            const addr2Balance = await hardhatToken.balanceOf(addr2.address);
            expect(addr2Balance).to.equal(50);
        });

        it("Should fail if sender doesn’t have enough tokens", async function () {
            const initialOwnerBalance = await hardhatToken.balanceOf(owner.address);

            // Try to send 1 token from addr1 (0 tokens) to owner (1000000 tokens).
            // `require` will evaluate false and revert the transaction.
            await expect(
                hardhatToken.connect(addr1).transfer(owner.address, 1)
            ).to.be.revertedWith("Not enough tokens");
            // Dùng await ở ngoài tương tự chờ cái bên trong chạy xong. Hoặc là dùng await bên trong rồi mới gọi expect, cách nào cũng được

            // Owner balance shouldn't have changed.
            expect(await hardhatToken.balanceOf(owner.address)).to.equal(
                initialOwnerBalance
            );
        });

        it("Should update balances after transfers", async function () {
            const initialOwnerBalance = await hardhatToken.balanceOf(owner.address);

            // Transfer 100 tokens from owner to addr1.
            await hardhatToken.transfer(addr1.address, 100);

            // Transfer another 50 tokens from owner to addr2.
            await hardhatToken.transfer(addr2.address, 50);

            // Check balances.
            const finalOwnerBalance = await hardhatToken.balanceOf(owner.address);
            expect(finalOwnerBalance).to.equal(initialOwnerBalance - 150);

            const addr1Balance = await hardhatToken.balanceOf(addr1.address);
            expect(addr1Balance).to.equal(100);

            const addr2Balance = await hardhatToken.balanceOf(addr2.address);
            expect(addr2Balance).to.equal(50);
        });
    });
});

// Mọi thứ cài trong hardhat đều quy về 1 biến hre là biến chứa mọi chức năng của hardhat, VD ethers cx là 1 trường của biến hre khai báo bên trên mà thôi. Các biến global có thể dùng trực tiếp luôn. Các thứ như plugin, config, task đều được add vào hre làm cho nó đc truy cập mọi nơi
const hre = require("hardhat");
const assert = require("assert");
// console.log("HRE: ", hre); // Là 1 object chứa hết các thứ

describe("Hardhat Runtime Environment", function () {
    it("should have a config field", function () {
        assert.notEqual(hre.config, undefined);
    });
});