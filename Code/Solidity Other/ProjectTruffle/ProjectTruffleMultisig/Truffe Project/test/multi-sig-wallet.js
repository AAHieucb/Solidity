const { assert } = require("chai");
const chai = require("chai");
chai.use(require("chai-as-promised"));
// chai chỉ dùng đúng 2 thư viện này viết test

const expect = chai.expect;

// artifacts là biến global của truffle, tạo instancce của contract có tên là gì
const MultiSigWallet = artifacts.require("MultisignatureWallet");
console.log(artifacts);

// Contract sẽ báo hiệu bên trong là test, truffle tự nhận diện và cho luôn accounts lưu tk
contract("MultisignatureWallet", accounts => {
    const owners = [accounts[0], accounts[1], accounts[2]];
    const NUM_CONFIRMATIONS_REQUIRED = 2
    
    // Ở đây mỗi test t tạo ra 1 multisigwallet mới luôn
    let wallet;
    beforeEach(async() => {
        wallet = await MultiSigWallet.new(owners, NUM_CONFIRMATIONS_REQUIRED); // Code deploy
    })
    
    describe("executeTransaction", () => {
        // Có code trùng ta nhét vào beforeEach, nhưng ta chỉ muốn phần code này thực hiện với riêng 2 test này mà thôi nên ta nhét vào 1 describe
        beforeEach(async() => {
            await wallet.submitTransaction(owners[0], 0, "0x00"); // Specific người thực hiện transaction(msg.sender), mặc định là owners[0]
            await wallet.confirmTransaction(0, {from: owners[0]});
            await wallet.confirmTransaction(0, {from: owners[1]});
        })
        it("should execute", async() => {
            const res = await wallet.executeTransaction(0, {from: owners[0]});
            const {logs} = res;
            // Khi lấy giá trị trả về của 1 transaction sau khi gọi thì nó chứa toàn bộ những thứ cần thiết của function đó như event chẳng hạn, các thứ hiện ra như ở console của remix, logs là chuyên chứa event
            console.log("Res: ", res);
            assert.equal(logs[0].event, "ExecuteTransaction");
            assert.equal(logs[0].args.owner, owners[0]);
            assert.equal(logs[0].args.txIndex, 0);
            
            const tx = await wallet.getTransaction(0);
            assert.equal(tx.executed, true);
        })
        it("should reject if already executed", async() => {
            await wallet.executeTransaction(0, {from: owners[0]}); // Thành công nên bên dưới sẽ sai
            // try{
            //     await wallet.executeTransaction(0, {from: owners[0]});
            //     throw new Error("tx did not fail"); // Nếu k có lỗi thì mới là sai và cần throw lỗi
            // }catch(error){
            //     assert.equal(error.reason, "tx already executed"); // Là cái ta throw ở require trong contract
            // }
            // Hàm bên trên của mocha cồng kềnh ở chỗ, ta muốn 1 hàm fail thì phải check nó fail thì bắt đúng lỗi là ok nhưng check nó đúng thì throw 1 cái error khác. chai-as-promised cho ta cách test ngắn gọn như dưới
            await expect(wallet.executeTransaction(0, {from: owners[0]})).to.be.rejected; // K cần try catch
        })
    })
})
