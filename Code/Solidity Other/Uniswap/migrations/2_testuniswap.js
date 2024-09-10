const Migrations = artifacts.require("TestUniswap");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
