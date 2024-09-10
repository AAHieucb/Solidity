// Cái này đã deploy fix trên rinkeby rồi, có thể sau này reset mọi thứ sẽ khác thì phải deploy lại
// Ở đây ta deploy nó bằng remix vào rinkeby xong vào đây viết file tương tác với mạng rinkeby luôn mà k cần truffle gì hết
const privateKey = "45ca7539ccb548d938ed418f32363a579963b03347f656a78bd3503d4b00bd20";
const infuraUrl = "https://rinkeby.infura.io/v3/c4b042ef643743d69bf378263e806024";
const permit =  require('eth-permit');
const { ethers } = require('ethers');

const test = async() => {
    const wallet = new ethers.Wallet(privateKey, new ethers.providers.JsonRpcProvider(infuraUrl));
    const senderAddress = "0xe0b173BFfC297d9C711D78E888974d8Cd59072Ac";
    const tokenAddress = "0x8c28025C39a7cD149e4610D49a724C9B40Ce360A";
    const spender = "0xdC9CeE7B93794197e84F1899C7FC4C824eB6226b";
    const value = 500000000000000;
    const result = await permit.signERC2612Permit(wallet, tokenAddress, senderAddress, spender, value);
    // Hàm signERC2612Permit nhận provider là 1 wallet(gắn liền với account). Có 2 loại provider: 1 là provider của hẳn 1 node là API của ethereum blockchain, 2 là provider của 1 wallet gắn với 1 tk thì nó chỉ nhận loại 2. Do đó ta tạo các kiểu provider khác nó éo hoạt động mà tạo provider wallet của ethersJS thì lại hđ ok
    // VD tương tự dùng window.ethereum của front end mà chạy vào metamask chính là provider wallet đó. K thể dùng hdwallet-provider của truffle ở đây vì nó chỉ dùng trong dự án truffle và cấu trúc cx k phù hơp
    console.log(result);
}
test();