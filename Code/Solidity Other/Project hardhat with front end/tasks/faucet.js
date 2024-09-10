// # Thao tác hardhat / Dùng task
// Chạy bằng npx hardhat faucet <receiverAddress>

const fs = require("fs");

// This file is only here to make interacting with the Dapp easier,
// feel free to ignore it if you don't need it.

task("faucet", "Sends ETH and tokens to an address")
  .addPositionalParam("receiver", "The address that will receive them")
  // positionalParam hình như là param chỉ cố định vị trí này ấy, các param bth là variadic param
  .setAction(async ({ receiver }) => {
    if (network.name === "hardhat") {
      console.warn(
        "You are running the faucet task with Hardhat network, which" +
          "gets automatically created and destroyed every time. Use the Hardhat" +
          " option '--network localhost'"
      );
    }

    const addressesFile =
      __dirname + "/../frontend/src/contracts/contract-address.json";

    // Check contract cần được deploy trước khi chạy task, sau khi deploy sẽ ghi thông tin vào file trên
    if (!fs.existsSync(addressesFile)) {
      console.error("You need to deploy your contract first");
      return;
    }

    const addressJson = fs.readFileSync(addressesFile);
    const address = JSON.parse(addressJson);

    // ethers.provider trả ra provider của cái configuration này
    // Còn getCode(address, (blockTag)); trả ra contract code of address theo blockTag block height, k có contract trả ra 0x. Ở đây ta lấy contract code từ address sau khi deploy và kiểm tra xem contract code của nó có tồn tại k, có thì ok. Tức ta check file tồn tại, sau đó check address contract có được deploy SM trên đó
    if ((await ethers.provider.getCode(address.Token)) === "0x") {
      console.error("You need to deploy your contract first");
      return;
    }

    const token = await ethers.getContractAt("Token", address.Token);
    const [sender] = await ethers.getSigners();

    // Để faucet: gửi tiền từ contract vào receiver. Nó mặc định được gửi từ signers[0]
    const tx = await token.transfer(receiver, 100);
    await tx.wait();

    const tx2 = await sender.sendTransaction({
      to: receiver,
      value: ethers.constants.WeiPerEther,
    });
    await tx2.wait(); // transfer hay gọi hàm transaction hay sendTransaction đều là biến type Transaction của etherjs. Đây là cách sendETH trong hardhat

    // Phân biệt: @nomiclabs/hardhat-waffle ethers
    /*
      <contract factory>.deploy(<params>, {value: <>}); => có list các override luôn
      <signer>.sendTransaction({ to: <>, from: <>, value: <> }) => có list transaction request, chỉ gửi tiền trường data của transaction request giúp gửi ether cho 1 contract khác nhưng k tiện
      ethers.provider.sendTransaction(<biến transaction đã signed>) => provider là global cung thông tin về blockchain data 
      <instance deployed>.<gọi hàm>(<para>, { <override> });
    */
    /*
      Hàm wait: ta dùng để chờ mined -> vì gọi hàm await deploy() là chờ nó send lên thôi. Với các transaction thì ta nên gọi wait ngay sau khi gọi hàm chờ khi có dữ liệu r thì ta mới thao tác với dữ liệu
    */

    console.log(`Transferred 1 ETH and 100 tokens to ${receiver}`);
  });
console.log(typeof task);