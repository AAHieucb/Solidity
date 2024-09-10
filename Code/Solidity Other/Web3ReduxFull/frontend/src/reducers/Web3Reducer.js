import {UPDATE_WEB3} from "../actions/constants";

const DEFAULT_STATE_WEB3 = {
    web3: null,
    netId: 0,
    account: "0x00"
}

const reducer = (state = DEFAULT_STATE_WEB3, action) => {
    switch(action.type){
        case UPDATE_WEB3:
            const netId = action.data.networkId || state.netId;
            const web3 = action.data.web3 || state.web3;
            const account = action.data.account || state.account;
            return{
                ...state,
                netId,
                web3,
                account
            }
        default: 
            return state;
    }
}
export default reducer;