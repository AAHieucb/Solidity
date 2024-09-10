const MultisignatureWallet = artifacts.require("MultisignatureWallet");

// Nếu ta gõ: truffle develop -> migrate => thì nó sẽ deploy vào chain truffle develop đó 
module.exports = function (deployer, network, accounts) {
    const owners = accounts.slice(0, 3); 
    const numConfirmationRequired = 2;
    deployer.deploy(MultisignatureWallet, owners, numConfirmationRequired); // Truyền tham số cho constructor
};
