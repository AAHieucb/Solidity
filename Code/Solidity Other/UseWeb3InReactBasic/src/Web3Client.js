import Web3 from "web3";
import NFTContractBuild from "contracts/NFT.json";

// ***Thay vì ta copy file json thì ta có thể import 1 phát từ file json gốc luôn. Như v mỗi lần build 1 phát ăn luôn. Còn nếu copy thì mỗi lần contract được build lại trên blockchain khác thì phải copy lại như dự án multisig
// => Tuy nhiên nếu cố tình import từ 1 file ngoài dự án sẽ bị lỗi. Ở đây ta thêm dependencies vào package.json nên ở đây ta chỉ refer đến đường link gần nó nhất như này là cách tốt nhất hiện tại => cách này chỉ dùng với dự án nhỏ khi front và contract chạy chung máy
// Chú ý đường dẫn trong package.json có scheme => sau khi thêm, ta phải chạy npm install lại để nó thêm vào node_modules

var NFTContract;
let erc20Contract;
let selectedAccount;
// Cái biến này sẽ luôn bắt account mới nhất, các chỗ khác dùng nó thì luôn là mới nhất
export const init = () => {
    let provider = window.ethereum; 
		// Trong file ts dùng window.ethereum báo lỗi, nch là cứ dùng được cái gì thì lấy

    if(typeof provider !== undefined){
			provider.request({method: "eth_requestAccounts"})
			.then((accounts) => {
					selectedAccount = accounts[0];
					console.log("Account change to: ", selectedAccount);
			})
			.catch((err) => {
					console.log(err)
			})
			// Quá hay, bh nó bắt sự kiện chứ éo cần phải làm thủ công như cái multisig check setInterval từng giây một như khi dùng web3 đời cũ
			window.ethereum.on("accountsChanged",function(accounts){
				selectedAccount = accounts[0];
				console.log("Account change to: ", selectedAccount);
			})
    }
    const web3 = new Web3(provider);
    const networkId = web3.eth.net.getId();
    NFTContract = new web3.eth.Contract(NFTContractBuild.abi, NFTContractBuild.networkId[networkId].address);

    // Đặt vấn đề là bh ta cần tương tác với contract DAI ở test net mà kp do ta deploy, để lấy được thì ta cần abi và address thì abi của DAI chính là abi của token erc20 với các hàm giống. Để tối giản, ta chỉ cần copy phần abi của hàm ta cần dùng ở đây là balanceOf
    const erc20Abi = [
		{
			constant: true,
			inputs: [
				{
					name: '_owner',
					type: 'address'
				}
			],
			name: 'balanceOf',
			outputs: [
				{
					name: 'balance',
					type: 'uint256'
				}
			],
			payable: false,
			stateMutability: 'view',
			type: 'function'
		}
	];
	erc20Contract = new web3.eth.Contract(
		erc20Abi,
		// Dai contract on Rinkeby
		'0x5592ec0cfb4dbc12d3ab100b257153436a1f0fea'
	);
} 
export const getOwnBalance = async () => {
	return erc20Contract.methods
		.balanceOf(selectedAccount)
		.call()
		.then((balance) => {
			return Web3.utils.fromWei(balance); // Hiển thị theo đúng đơn vị nhân với 10**-18
		});
};

export const mintToken = async() => {
	// Thực hiện tx bằng web3 với instance contract
	return NFTContract.methods.mint(selectedAccount).send({from: selectedAccount})
}
