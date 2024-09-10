import { UpdateAccount, Web as State, UPDATE_ACCOUNT } from "../actions/index";

export const INITIAL_STATE_WEB3: State = {
    account: "0x00",
    web3: null,
    netId: 0
}

type Action = UpdateAccount;
// Chú ý định nghĩa interface như 1 struct trong C++ v, là 1 tập hợp các biến có kiểu dữ liệu xác định gộp thành 1 kiểu dữ liệu mới ta tạo ra mà thôi. Dòng type này như kiểu đặt typedef tức cho 1 cái tên khác thôi

export function web3Reducer(state: State = INITIAL_STATE_WEB3, action: Action) {
    switch(action.type) {
        case UPDATE_ACCOUNT: {
            const web3 = action.web3 || state.web3;
            const netId = action.netId || state.netId; // Nếu có thì update, k thì lấy giá trị cũ k đổi
            const { account } = action;
            return {
                ...state,
                web3,
                account,
                netId
            };
        }
        default: 
            return state;
    }
}