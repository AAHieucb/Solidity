// Lập trình blockchain / # Web3 / # Tương tác với event

// VD lấy event có địa chỉ dùng indexed bất kỳ ở 1 đồng coin trong mạng ethereum là Dai StableCoin. Giá luôn dao động cố định ở 1 dola 1 coin => Thôi chuyển qua Sai StableCoin cho dễ: https://etherscan.io/address/0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359#code

const Web3 = require("web3");
// Web3 là cầu nối mọi blockchain với Nodejs, JS, sẽ lấy, gửi dữ liệu trans trong blockchain

const abi = require("./abi.json"); // require file abi như này
// abi là application binary interface: giúp tương tác với smart contract trong blockchain. Nó định nghĩa cấu trúc các hàm để ta gọi được. Vì bản chất đồng coin này được tạo ra từ 1 smart contract. Mọi token đều xuất phát từ 1 smart contract mà mn tạo transaction dù tạo ra trong block mới nhưng đều tương tác với nó. Mỗi smart contract như v đều có 1 ABI. Ta vào trang web Etherscan phần address code contract để lấy ABI:
// https://etherscan.io/address/0x6b175474e89094c44da98b954eedeac495271d0f#code
// => Có thể tải source code của nó về chạy thử or tương tác trực tiếp qua: 
// https://etherscan.io/token/0x6b175474e89094c44da98b954eedeac495271d0f#readContract

const INFURAL_URL = "https://mainnet.infura.io/v3/eca64c547908458d815f129e14d67083"
// Để chạy web3 tương tác được với blockchain, ta cần fullnode của Ethereum blockchain (mới vào được các block xa lắc xa lơ). Nhưng cách khác là dùng API của infura để lấy mọi thứ của ethereum blockchain (thực tế infura cũng conncet với 1 fullnode và cung url API ra thôi)
// Để có infura_url, ta cần tạo tk trên infura.io rồi tạo 1 project mới với ether blockchain. Sau đó copy đường link để dùng, dùng link này trong các lib như web3.js để lấy dữ liệu về blockchain ethereum chẳng hạn. Nó sẽ thống kê số lần dùng API infura ở mục stats

const address = "0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359"; // VD Contract address of SAI StableCoin

const web3 = new Web3(INFURAL_URL); // Ta k gọi hàm gì đổi state của chain nên k cần piv/pub key

async function main(){
    const lastest = await web3.eth.getBlockNumber();
    console.log("Lastest block: ", lastest);
    const id = await web3.eth.net.getId();
    console.log("Net id: ", id);

    const contract = new web3.eth.Contract(abi, address); // Lấy thông tin contract tạo ra coin này
    
    // Trong các contract tạo coin đó, lấy các sự kiện trong quá khứ có tên Transfer đã qua
    const logs = await contract.getPastEvents("Transfer", {
        fromBlock: lastest - 1000000,
        toBlock: lastest,
        filter: { dst: "0x56D037d72ACdBf7c43B5addB6E5C8327f9Ac00CC" }
        // Tất cả các trường nào của event có indexed đều có thể lọc ra với hàm filter, trong source code thì dst là địa chỉ có indexed
    }) // => Là được 1 mảng chứa các event
    console.log("Logs", logs, `${logs.length}`)
    console.log(
        "Senders",
        logs.map(log => log.returnValues.dst),
        // Chỉ hiển thị các dst
    )
}
main();
console.log(web3.eth.defaultBlock);
// defaultBlock là "lastest", có thể chỉnh lại bằng cách gán = "earliest" or "pending" or 1 số cụ thể

// Hàm web3.eth.getStorageAt(address, position [, defaultBlock] [, callback]) sẽ lấy dữ liệu ở storage của contract
// VD: web3.eth.getStorageAt("0x2f7265005a7c067c4b683964b6b400030a272e2f", 0, (e,r) => alert(r)) thì 1 là địa chỉ của contract muốn lấy dữ liệu(sau khi deploy r), 2 là vị trí trong storage muốn lấy(VD có 2 biến trong storage là state var của 1 contract ta muốn lấy biến thứ nhất thì dùng 0), 3 là callback function(error, result)
