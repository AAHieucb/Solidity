module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id. Tức là bất cứ mạng blokchain nào có host và chạy ở port này đều đc quyền kết nối vào
    },
    develop: {
      port: 8545
    }
  }
};
