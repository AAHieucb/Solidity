const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('Receiver ERC1155', async () => {
  let erc1155, receiverERC1155;
  let deployer;
  let tokenId = '0';

  beforeEach(async () => {
    [deployer] = await ethers.getSigners();

    let TestERC1155 = await ethers.getContractFactory('GameItems');

    erc1155 = await TestERC1155.connect(deployer).deploy();

    let ReceiverERC1155 = await ethers.getContractFactory('Receiver');

    receiverERC1155 = await ReceiverERC1155.connect(deployer).deploy();
  });

  it.only('All setup successfully', async () => {
    await erc1155
      .connect(deployer) // connect là bảo địa chỉ nào sẽ gọi hàm
      .functions['safeTransferFrom(address,address,uint256,uint256,bytes)'](
        deployer.address,
        receiverERC1155.address,
        tokenId,
        '10',
        '0x00'
      );

    console.log('Deployer address: ', deployer.address);
    console.log('Receiver ERC1155 address: ', receiverERC1155.address);
    console.log('Deployer balance:', parseInt(await erc1155.balanceOf(deployer.address, tokenId)));
    console.log(
      'Receiver ERC1155 balance: ',
      parseInt(await erc1155.balanceOf(receiverERC1155.address, tokenId))
    );
  });
});