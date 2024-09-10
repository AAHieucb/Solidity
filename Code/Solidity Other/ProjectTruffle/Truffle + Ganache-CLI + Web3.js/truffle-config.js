module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 9545,
      network_id: '*'
    }
  }
}
// Truffle có sẵn web3 dùng bất cứ đâu
// web3.eth.getBalance(address).then(balance => {console.log(balance);}).catch(console.error);