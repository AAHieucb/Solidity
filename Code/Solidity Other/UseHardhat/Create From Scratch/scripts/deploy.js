console.log("2");

async function main() {
    const [deployer] = await ethers.getSigners(); // ethers trong hre lấy trực tiếp như này
    // 1 ví có nhiều account và hàm này lấy ra mảng các account của ví đó, đang lấy phần tử đầu tiên là master account[0]
    // console.log(hre); // quá lớn
    console.log(hre.ethers.constants.AddressZero);
    console.log(hre.ethers.provider.getNetwork().chainId);

    console.log("3");

    console.log("Deploying contracts with the account:", deployer.address);

    console.log("Account balance:", (await deployer.getBalance()).toString());

    const Token = await ethers.getContractFactory("Token");
    const token = await Token.deploy();

    console.log("Token address:", token.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });