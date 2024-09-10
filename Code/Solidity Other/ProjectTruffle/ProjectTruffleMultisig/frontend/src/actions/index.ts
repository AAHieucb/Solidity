import BN from "bn.js"; // Cái này nó là 1 type
import Web3 from "web3";

// Web3 action
export const UPDATE_ACCOUNT = "UPDATE_ACCOUNT";

// Data Contract Action
export const SET = "SET";
export const UPDATECONFIRM = "UPDATECONFIRM";
export const UPDATEREVOKE = "UPDATEREVOKE";
export const UPDATEEXECUTE = "UPDATEEXECUTE";
export const UPDATESUBMIT = "UPDATESUBMIT";

// Interface for Data Contract
export interface Transaction{ // Chú ý interface có dấu ; chứ kp ,
    txIndex: number;
    to: string;
    value: BN;
    executed: boolean;
    data: string;
    numComfirmation: number;
    isConfirmedByCurrentAccount: boolean; 
}
export interface Data{
    numConfirmationRequired: number;
    owners: string[];
    balance: string;
    transactionCount: number;
    address: string;
    transactions: Transaction[];
}

// Interface for Data Contract Action
export interface Set{
    type: "SET",
    data: Data
}
export interface UpdateConfirm{
    type: "UPDATECONFIRM"; // Ép buộc type là hs được như này chứ k cần type: string
    data: {
        txIndex: string;
        confirmed: boolean;
    }
}
export interface UpdateRevoke{
    type: "UPDATEREVOKE";
    data: {
        txIndex: string;
        confirmed: boolean;
    }
}
export interface UpdateExecute{
    type: "UPDATEEXECUTE";
    data: {
        txIndex: string;
    }
}
export interface UpdateSubmit{
    type: "UPDATESUBMIT";
    data: Transaction;
}

// Interface for Web3 
export interface Web {
    account: string;
    web3: Web3 | null;
    netId: number;
}

// Interface for Web3 action
export interface UpdateAccount {
    type: "UPDATE_ACCOUNT";
    account: string;
    web3?: Web3;
    netId?: number;
    // Web3 là optional vì lần update đầu tiên thì biến web3 có dữ liệu nhưng về sau ng dùng update thì web3 là null ok luôn và ta chỉ cần lấy account thôi
}