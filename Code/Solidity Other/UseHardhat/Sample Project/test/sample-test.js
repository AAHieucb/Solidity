const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const Greeter = await ethers.getContractFactory("Greeter");
    const greeter = await Greeter.deploy("Hello, world!");
    await greeter.deployed();

    expect(await greeter.greet()).to.equal("Hello, world!");

    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait() until the transaction is mined
    // Chỉ khi nào là transaction mới dùng được các hàm của transaction k thì chỉ là giá trị trả về bth
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mudo!");
  });
});
