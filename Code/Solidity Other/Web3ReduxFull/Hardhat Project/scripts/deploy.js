// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const UserData = await hre.ethers.getContractFactory("UserData");
  const userData = await UserData.deploy();

  await userData.deployed();

  console.log("UserData deployed to:", userData.address);
  
  saveFrontEndFiles(userData);
}

function saveFrontEndFiles(userData){
  const fs = require("fs");
  const contractsDir = __dirname + "/../build";

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    contractsDir + "/contract-address.json",
    JSON.stringify({ UserData: userData.address }, undefined, 2)
  );

  const TokenArtifact = artifacts.readArtifactSync("UserData");
  // Sau khi deploy thì gọi hàm này sẽ lấy ra mọi thông tin

  fs.writeFileSync(
    contractsDir + "/data-build.json",
    JSON.stringify(TokenArtifact, null, 2)
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
