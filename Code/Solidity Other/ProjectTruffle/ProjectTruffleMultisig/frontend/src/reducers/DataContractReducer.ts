import { SET, UPDATECONFIRM, UPDATEREVOKE, UPDATEEXECUTE, UPDATESUBMIT, Set, UpdateConfirm, UpdateRevoke, UpdateExecute, UpdateSubmit, Data } from "../actions/index";

type State = Data
export const INITIAL_STATE_DATA_CONTRACT: State = {
    numConfirmationRequired: 0,
    owners: [],
    balance: "0",
    transactionCount: 0,
    address: "0x00",
    transactions: []
}

// interface Action extends State { // Dùng như này chứ dùng toán tử OR | nó éo chạy, OR chỉ dùng với type
//     type: string // Lưu như này k tốt vì nó k tách ra trường data như dưới
// }
// interface Action {
//     type: string,
//     data: State
// } // Cần nh action thì như này k tốt mà dùng toán tử OR

type Action = Set | UpdateConfirm | UpdateRevoke | UpdateExecute | UpdateSubmit;
// Làm như này thì action là 1 trong các cái này
export function dataContractReducer(state: State = INITIAL_STATE_DATA_CONTRACT, action: Action){
    // state ở trong đây lưu đủ mọi thứ luôn, ta phải return ...state sau đó thêm những thứ thay đổi
    console.log(action.data);
    switch(action.type){
        case SET: {
            return{
                ...state,
                ...action.data
            }
        }
        case UPDATECONFIRM: {
            const {data} = action; // Thg lấy như thế này
            const txIndex = parseInt(data.txIndex);
            console.count("Should run only one")
            const transactions = state.transactions.map((tx) => {
                if(tx.txIndex == txIndex){
                    return{
                        ...tx,
                        numComfirmation: tx.numComfirmation + 1,
                        isConfirmedByCurrentAccount: data.confirmed
                    }
                }else{
                    return{
                        ...tx
                    }
                }
            })
            return{
                ...state,
                transactions: transactions
            }
        }
        case UPDATEREVOKE: {
            const {data} = action;
            const txIndex = parseInt(data.txIndex);
            const transactions = state.transactions.map((tx) => {
                if(tx.txIndex == txIndex){
                    return{
                        ...tx,
                        numComfirmation: tx.numComfirmation - 1,
                        isConfirmedByCurrentAccount: !data.confirmed
                    }
                }else{
                    return{
                        ...tx
                    }
                }
            })
            return{
                ...state,
                transactions: transactions
            }
        }
        case UPDATEEXECUTE: {
            const {data} = action;
            const txIndex = parseInt(data.txIndex);
            const transactions = state.transactions.map((tx) => {
                if(tx.txIndex == txIndex){
                    return{
                        ...tx,
                        executed: true
                    }
                }else{
                    return{
                        ...tx
                    }
                }
            })
            return{
                ...state,
                transactions: transactions
            }
        }
        case UPDATESUBMIT:{
            const { data } = action;
            const transactions = [
                {
                    txIndex: data.txIndex,
                    to: data.to,
                    value: data.value,
                    // Trong file tsx k dùng parseInt mà chỉ được trong file ts.
                    // Dùng được các thư viện của NodeJs nên phải dùng Web3.utils.toBN. Còn toNumber là hàm của type string
                    executed: false,
                    data: data.data,
                    numComfirmation: 0,
                    isConfirmedByCurrentAccount: false
                },
                ...state.transactions
            ]
            return{
                ...state,
                transactions: transactions
            }
        }
        default:
            return state;
    }
}