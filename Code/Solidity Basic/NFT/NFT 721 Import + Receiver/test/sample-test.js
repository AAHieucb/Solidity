const { expect } = require("chai");
const { ethers } = require("hardhat");

// # Viết test
describe('Receiver ERC721 2', async () => {
  let erc721, receiverERC721_2;
  let deployer, user, anotherUser;
  let tokenId = '0';

  beforeEach(async () => {
    [deployer, user, anotherUser] = await ethers.getSigners();

    let TestERC721 = await ethers.getContractFactory('MyNFTERC721');

    erc721 = await TestERC721.connect(deployer).deploy();

    let ReceiverERC721_2 = await ethers.getContractFactory('Receiver');

    receiverERC721_2 = await ReceiverERC721_2.connect(deployer).deploy();
    // Hàm connect trả ra instance mới contractFactory nhưng với signer là deployer -> hàm chỉ định ng deploy mà thôi
  });

  it.only('All setup successfully', async () => {
    await erc721.connect(deployer).mint(user.address, tokenId);

    let data = erc721.interface.encodeFunctionData('transferFrom', [
      receiverERC721_2.address,
      anotherUser.address,
      tokenId
    ]);

    await erc721
      .connect(user)
      .functions['safeTransferFrom(address,address,uint256,bytes)'](
        user.address,
        receiverERC721_2.address,
        tokenId,
        data
      );

    console.log('User address: ', user.address);
    console.log('Another user address: ', anotherUser.address);
    console.log('Receiver ERC721 address: ', receiverERC721_2.address);
    console.log('NFT owner: ', await erc721.ownerOf(tokenId));
    // Lượng token đã được gửi cho another user
  });
});