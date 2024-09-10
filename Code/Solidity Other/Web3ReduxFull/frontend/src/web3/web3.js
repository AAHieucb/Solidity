import Web3 from "web3";

export async function unlockAccount(callback){
    var selectedAccount;
    var web3;
    var networkId;
    const provider = window.ethereum;
    if(typeof provider == undefined){
        throw Error("Window ethereum not enable");
    }
    const accounts = await provider.request({method: "eth_requestAccounts"})
    selectedAccount = accounts[0];
    window.ethereum.on("accountsChanged", function(accounts){
        selectedAccount = accounts[0];
        // Thử để Updater gọi hàm này 1 lần lúc render xem, nó sẽ kbh render lại mà chỉ chạy 1 lần từ đầu tới cuối
        // Khi nào unmount thì phải remove event
        callback(selectedAccount, null);
    })
    window.ethereum.on('chainChanged', (chainId) => {
        callback(null, chainId);
    });
    web3 = new Web3(provider);
    networkId = await web3.eth.net.getId();
    // contract = new web3.eth.Contract();
    return {
        selectedAccount, web3, networkId
    }
}