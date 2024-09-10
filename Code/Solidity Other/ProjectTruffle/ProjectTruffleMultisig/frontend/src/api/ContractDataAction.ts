import Web3 from "web3";
import TruffleContract from "@truffle/contract";
import multisigWallet from "../contracts/MultisignatureWallet.json";
// Nó báo lỗi ảo trong typescript, khi compile vẫn ngon thôi nên cứ ignore
import { Transaction } from "../actions/index";
import BN from "bn.js";
import { Data as GetResponse } from "../actions/index";

//@ts-ignore
const MultiSigWallet = TruffleContract(multisigWallet);

// Hàm này lấy web3 để access vào balance và trong contract cx k có hàm getBalance làm gì vì web3 có sẵn r
// Hàm này còn lấy account để ta còn check account này đã confirm chưa nx chứ
export async function getData(web3: Web3, account: string): Promise<GetResponse>{
    MultiSigWallet.setProvider(web3.currentProvider); // Ý là provider đã dùng r thì mới gọi đến dây thì nó dùng tiếp cái đó, ở đây là window.ethereum

    const contractInstance = await MultiSigWallet.deployed();
    const balance = await web3.eth.getBalance(contractInstance.address);
    const owners = await contractInstance.getOwners();
    const numConfirmationRequired = await contractInstance.numConfirmationRequired();
    const transactionCount: BN = await contractInstance.getTransactionCount();
    console.log("transactionCount: ", transactionCount); // uint trong solidity sang JS tự thành kiểu BN or string
    // VD khi viết contract ta tinh ý trong việc viết các hàm get ví dụ ở đây ta có luôn hàm get như này nhờ ta đã định nghĩa trong contract. Nếu k đc thì ta có thể lấy 1 list cái transaction rồi tính length của nó nhưng điều này là tối kỵ vì viết 1 hàm return mảng các transaction sẽ nguy cơ out of gas
    // Còn isConfirmed tương tự, ta chủ đích viết các hàm get cho các thứ ta dùng ở front end
    const count: number = transactionCount.toNumber(); // Phải convert về number từ BN
    const transactions: Transaction[] = [];
    for(var i = 1; i <= 10; i++){
        const txIndex = count - i;
        if(txIndex < 0)
            break;
        const transTemp = await contractInstance.getTransaction(txIndex);
        const isConfirmedByCurrentAccount = await contractInstance.isConfirmed(txIndex, account)
        //@ts-ignore
        console.log(transTemp);
        transactions.push({
            txIndex,
            to: transTemp.to,
            value: transTemp.value, 
            executed: transTemp.executed,
            data: transTemp.data,
            numComfirmation: transTemp.numConfirmations.toNumber(),//luôn chú ý kiểu số
            isConfirmedByCurrentAccount: isConfirmedByCurrentAccount
        })
    }
    return {
        numConfirmationRequired: numConfirmationRequired.toNumber(),
        owners,
        balance,
        transactionCount: count,
        address: contractInstance.address,
        transactions
    }
}

export async function depositContract(web3: Web3, account: string, value: BN){
    MultiSigWallet.setProvider(web3.currentProvider);
    const contractInstance = await MultiSigWallet.deployed();
    await contractInstance.sendTransaction({from: account, value: value})
}
// Về cấu trúc file ta có thể tách ra deposit ra file khác vì file này chỉ nên dùng cho data initialization. Nch là tính năng deposit là do hàm ở front end gọi luôn vì có thao tác ấn nút mới thực hiện

// Hàm bắt subscribeEvent cập nhập balance
export function subscribeToEvent( // Subscribe trnog web3 có sẵn và nó kp là hàm async
    web3: Web3, 
    address: string,
    callback: (error: Error | null, log: any) => void // Chú ý type function có return gì k nhé. K được dùng kiểu => { } là buộc có return gì đó
){
    console.log("Call subscribe to Event");
    //@ts-ignore
    const contractInstance = new web3.eth.Contract(multisigWallet.abi, address);
    const res = contractInstance.events.allEvents((error: Error, log: any) => {
        // Chú ý: xử lý như này là quá bth vì ta viết ở đây nhưng k muốn hàm này xử lý luôn mà muốn giao cho 1 hàm gọi nó xử lý thì có thể dùng như này, lấy 2 cả 2 thứ là error và data. VD hàm xử lý nó phải dùng biến account thì nó có luôn chứ hàm này k có biến account
        if(error) {
            console.log("call Callback")
            callback(error, null);
        }else if(log){
            console.log("call Callback")
            callback(null, log);
        }
    })
    return () => res.unsubscribe(); // Để hàm kia return hàm này luôn

    // Hàm useEffect khi return có vai trò rất quan trọng: nó sẽ return những giá trị mà có thể dừng cái hàm vô tận chạy bên trong useEffect hiện tại. Ta hiểu là useEffect nó được gọi nhiều lần tùy vào tham số phụ thuộc hook vào cái gì, nếu mỗi lần gọi nó chạy 1 hàm vô tận mà cứ bị gọi lại trong khi k dừng hàm sẽ cộng dồn gây lag trầm trọng. 
    // Giá trị hàm trong useEffect return bắt buộc phải là 1 function và function đó gọi hàm xóa => VD: ta return () => res.unsubscribe() thì ok nhưng return res.unsubscribe() thì lỗi ngay vì TH thứ 2 kp khai báo hàm mà có () tức là gọi hàm cmnr và giá trị trả về của vc gọi hàm được cast sang hàm số cho nó return.
}
export async function createTransaction(web3: Web3, account: string,
    params: { to: string, value: BN, dataT: string}
){
    const {to, value, dataT} = params;
    MultiSigWallet.setProvider(web3.currentProvider);
    const contractInstance = await MultiSigWallet.deployed();
    await contractInstance.submitTransaction(to, value, dataT, {
        from: account
    }); // Gọi hàm đơn giản hơn web3
}
export async function confirmTrans(web3: Web3, account: string, txIndex: number){
    MultiSigWallet.setProvider(web3.currentProvider);
    const contractInstance = await MultiSigWallet.deployed();
    await contractInstance.confirmTransaction(txIndex, {
        from: account
    });
}
export async function executeTrans(web3: Web3, account: string, txIndex: number){
    MultiSigWallet.setProvider(web3.currentProvider);
    const contractInstance = await MultiSigWallet.deployed();
    await contractInstance.executeTransaction(txIndex, {
        from: account
    });
}
export async function revokeTrans(web3: Web3, account: string, txIndex: number){
    MultiSigWallet.setProvider(web3.currentProvider);
    const contractInstance = await MultiSigWallet.deployed();
    await contractInstance.revokeConfirmation(txIndex, {
        from: account
    });
}