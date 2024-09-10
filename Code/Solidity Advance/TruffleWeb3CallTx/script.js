// Chạy: truffle migrate --network rinkeby --reset  để compile r deploy vào mạng rinkeby
// Chạy: node script.js  để làm mọi thứ

const Web3 = require('web3');
const MyContract = require('./build/contracts/MyContract.json');
const Provider = require("@truffle/hdwallet-provider");
const address = "0xe0b173BFfC297d9C711D78E888974d8Cd59072Ac";
const privateKey = "45ca7539ccb548d938ed418f32363a579963b03347f656a78bd3503d4b00bd20";
const infuraUrl = "https://rinkeby.infura.io/v3/c4b042ef643743d69bf378263e806024";

// # Web3 / # Tương tác với contract / Send transaction
// C1: Send tx qua chữ ký
const init1 = async () => {
    const web3 = new Web3(infuraUrl);
    const networkId = await web3.eth.net.getId();
    const myContract = new web3.eth.Contract(
        MyContract.abi,
        MyContract.networks[networkId].address
    );
    console.log(MyContract.networks[networkId].address) // Lấy địa chỉ của contract trên mạng rinkeby

    const tx = myContract.methods.setData(1);
    const gas = await tx.estimateGas({from: address});
    const gasPrice = await web3.eth.getGasPrice();
    const data = tx.encodeABI();
    const nonce = await web3.eth.getTransactionCount(address);

    // Hàm này nhờ privatekey mà ký transaction locally ở ngay dưới, sau đó ta send transaction đó vào mạng
    // Hàm này chỉ dùng ở backend vì nó nhúng thẳng pivkey vào code
    const signedTx = await web3.eth.accounts.signTransaction(
        { // Ký trans là cái object gửi từ sender tới <địa chỉ của trans>
            to: myContract.options.address, 
            data,
            gas,
            gasPrice,
            nonce, 
            chainId: networkId
        },
        privateKey
    );
    console.log(`Old data value: ${await myContract.methods.data().call()}`);
    const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    console.log(`Transaction hash: ${receipt.transactionHash}`);
    console.log(`New data value: ${await myContract.methods.data().call()}`);
}

// C2: Dùng hàm send gửi trực tiếp => dễ hơn
const init3 = async () => {
    const provider = new Provider(privateKey, infuraUrl); 
    // Nếu có nh pivkey thì [<các pivkey>] or mnemonic cx đc. Khi dùng provider nó tự sign cho ta r send
    const web3 = new Web3(provider);
    const networkId = await web3.eth.net.getId();
    const myContract = new web3.eth.Contract(
        MyContract.abi,
        MyContract.networks[networkId].address
    );

    console.log(`Old data value: ${await myContract.methods.data().call()}`);
    const receipt = await myContract.methods.setData(3).send({ from: address });
    console.log(`Transaction hash: ${receipt.transactionHash}`);
    console.log(`New data value: ${await myContract.methods.data().call()}`);
}
init3();