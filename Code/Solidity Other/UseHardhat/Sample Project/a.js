// Dùng @indexed-finance/multicall eth mainnet

const { ethers } = require("ethers");
const { MultiCall } = require("@indexed-finance/multicall");

const provider = new ethers.providers.JsonRpcProvider("https://mainnet.infura.io/v3/a7e587314d30461b81373362a952f723");
const multi = new MultiCall(provider);

const abi = [
  "function balanceOf(address) view returns (uint)",
  "function decimals() view returns (uint8)",
  "function symbol() view returns (string)",
];

const inputs = [
  {
    target: "0x6B175474E89094C44Da98b954EedeAC495271d0F",
    function: "balanceOf",
    args: ["0x5FbDB2315678afecb367f032d93F642f64180aa3"],
  },
  {
    target: "0x6B175474E89094C44Da98b954EedeAC495271d0F",
    function: "decimals",
  },
  {
    target: "0x6B175474E89094C44Da98b954EedeAC495271d0F",
    function: "symbol",
  },
];

multi.multiCall(abi, inputs).then((results) => {
  console.log(results);
});
