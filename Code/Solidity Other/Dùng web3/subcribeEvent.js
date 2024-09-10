const Web3 = require("web3");
const abi = require("./abi.json"); // Smart contract SAI coin
const INFURAL_URL = "wss://mainnet.infura.io/ws/v3/eca64c547908458d815f129e14d67083"; // API infura
const address = "0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359"; // Địa chỉ contract sai coin
const web3 = new Web3(new Web3.providers.WebsocketProvider(INFURAL_URL)); // LK app với api ethereum

// Để subcribe event thì phải dùng provider. Có 2 loại Provider là HttpProvider, WebsocketProvider:
// HttpProvider k còn dùng trong web3 để subcribe nx (deprecated), phải dùng WebsocketProvider mới đc vì subscribe là tương tác socket. Khi dùng như v thì url phải có scheme là wss or ws tùy TH
// Bth ta chạy 1 lần thì k cần provider, nhưng subscribe tức là nó luôn luôn bắt event khi nào có thì báo. Khi đó cần dùng 1 providers để liên kết liên tục với ether blockchain và app phải trong TT bật liên tục
async function main() {
    const contract = new web3.eth.Contract(abi, address);
    // events là trường của object contract lưu mọi event, Transfer là tên của event. Ta gọi hàm event Transfer() bị biến thành hàm có 2 đối số: 1 là object của events, ở đây ta lọc events; 2 là hàm số nhận vào 2 đối số: 1 là error nếu có lỗi, 2 là log là giá trị trả về nếu k có error, nó là object có length or returnValues,.. với returnValues là object trả ra các trường đã truyền vào event khi emit
    // => Hàm này sẽ chờ events này được gọi, miễn ta k tắt Ct nó sẽ chờ bắt sự kiện mãi
    contract.events.Transfer(
        {
            fromBlock: 0,
            filter: {src: "0x762d141b8D9600bde64138762E6Fb38Efc56dcBA"}
            // Chỉ cái nào được đánh indexed indexed mới có thể lọc bằng filter
        },
        (error, log) => {
            if(error)  
                console.log("Error: " + error);
            console.log("Log: " + log);
        }
    )
}

main();

console.log(web3.providers);
console.log(web3.eth.providers);//cả 2 cùng trả ra provider bình thường

//TK: 
//Nếu không gọi hàm trong contract: chỉ cần provider
//Nếu gọi hàm trong contract: 
//  Nếu là local ganache: có account sẵn ta chỉ cần lấy ra dùng => vẫn có thể cung pub/piv key của address nào nếu thích
//  Nếu là pubnet: buộc phải cung pub/piv key để có 1 địa chỉ nào đó
//Có sẵn account thì ez chỉ cần cung provider là ganache tự có account và ta gọi getAccounts để lấy
//Tự cung account thì buộc dùng wallet instance như @truffle/hdwallet-provider
//Để tương tác với contract dù có gọi hàm hay k đều phải lấy được instance của nó từ: abi và address