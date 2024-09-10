require("@nomiclabs/hardhat-waffle");

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      forking: {
        url: "https://eth.llamarpc.com",
        // blockNumber: 14390000, // fork từ block nào thay vì fork từ lastest block như mặc định
      },
      chainId: 1,
      // Yêu cầu mọi request tới mạng đều phải có Bearer token
      // httpHeaders: {
      //   Authorization: "Bearer <key>"
      // },

    },
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
}
