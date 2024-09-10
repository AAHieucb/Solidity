import Web3 from "web3";
import BN from "bn.js";
import UserDataContract from "contracts/data-build.json";
import ContractAddress from "contracts/contract-address.json";

let contractInstance = null;

function init(web3, netId){
    if(netId == 3)
        contractInstance = new web3.eth.Contract(UserDataContract.abi, ContractAddress.UserDataRopsten);
    else if(netId == 4)
        contractInstance = new web3.eth.Contract(UserDataContract.abi, ContractAddress.UserDataRinkeby);
}

export async function getInfo(web3, address, netId){
    init(web3, netId);
    const data = await contractInstance.methods.getUser(address).call();
    return data;
}

export async function addData(web3, address, data, netId){
    init(web3, netId);
    // Nếu để nguyên contract là Info memory tại sao lại k được??? làm xong quay lại check lỗi này
    await contractInstance.methods.addCurrent(data.age, data.name, data.description, data.avatar
        , address).send({from: address});
}
// Subscribe to event là hàm của web3 có sẵn mà ta k cần gọi async.
export function subscribeToEvents(web3, address, callback, netId){
    let web;
    let contractTest;
    if(netId == 3){
        web = new Web3(
            new Web3.providers.WebsocketProvider(
                "wss://eth-ropsten.alchemyapi.io/v2/5V4GIUUGdfNWeIUMN8VOf9IscNvRoT3S"));
        contractTest = new web.eth.Contract(UserDataContract.abi, ContractAddress.UserDataRopsten);
    }else if(netId == 4){
        web = new Web3(
            new Web3.providers.WebsocketProvider(
                "wss://eth-rinkeby.alchemyapi.io/v2/ZOSpigONF0-b13YjTtL8f9VluLCm9wDQ"));
        // web = new Web3(new Web3.providers.WebsocketProvider("ws://127.0.0.1:8545"));
        contractTest = new web.eth.Contract(UserDataContract.abi, ContractAddress.UserDataRinkeby);
    }
    const res = contractTest.events.AddCurrent({
        filter: {newAddress: address}
    }, (error, log) => {
        if(error)
            console.log(error);
        else 
            callback(log);
    })

    return () => {
        res.unsubscribe();
    }
}

export async function updateData(web3, address, data, netId){
    init(web3, netId);
    await contractInstance.methods.updateInfo(data.age, data.name, data.description, data.avatar, address).send({from: address});
}