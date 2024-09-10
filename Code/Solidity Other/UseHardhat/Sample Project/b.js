// Dùng @indexed-finance/multicall bsc testnet

const { ethers } = require("ethers");
const { MultiCall } = require("@indexed-finance/multicall");

const provider = new ethers.providers.JsonRpcProvider("https://data-seed-prebsc-1-s1.binance.org:8545");
const multi = new MultiCall(provider);

const abi = [
  "function balanceOf(address) view returns (uint)",
  "function decimals() view returns (uint8)",
  "function symbol() view returns (string)",
];

const inputs = [
  {
    target: "0xae13d989dac2f0debff460ac112a837c89baa7cd",
    function: "balanceOf",
    args: ["0x595622cBd0Fc4727DF476a1172AdA30A9dDf8F43"],
  },
  {
    target: "0xae13d989dac2f0debff460ac112a837c89baa7cd",
    function: "decimals",
  },
  {
    target: "0xae13d989dac2f0debff460ac112a837c89baa7cd",
    function: "symbol",
  },
];

multi.multiCall(abi, inputs).then((results) => {
  console.log(results);
});
