const Web3 = require('web3');
const MyContract = require('./build/contracts/DeveloperFactory.json');

// # Dùng truffle / Dùng web3 truffle

const init = async() => {
    const web3 = new Web3(process.env.PROVIDER_URL || 'http://localhost:9545');
    const id = await web3.eth.net.getId();
    const deployedNetwork = MyContract.networks[id];
    // Thật ra khi build ra kết quả nó sẽ cho ra file json như v. File này còn chứa cả thông tin của networkid, nó là 1 danh sách các network id mà contract này được deploy lên. Ở đây ta lấy thông tin contract ở đúng mạng hiện tại từ id web3.eth.net.getId()

    const contract = new web3.eth.Contract(
        MyContract.abi,
        deployedNetwork.address
    );
    // const result = await contract.methods.sayHello().call();
    contract.methods.createRandomDeveloper("Hieu", 18).send({ //Thực hiện tx
        from: '0x204D33f223F0Daadb647C72EAcAD41fED5DE04DB',
        value: 5000000000000000000,
        gas: 1000000 // Chỉnh gas cho chuẩn, nó tầm cỡ này
    }, function(error, transactionHash){
        console.log("transactionHash::", transactionHash);
    });
}

init();
// Khi build xong, thư mục build có chứa dữ liệu json của contract và trường abi chính là abi của contract, ngoài ra còn nhiều trường khác như network id