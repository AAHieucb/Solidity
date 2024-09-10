import React, { useReducer, createContext, useContext, useEffect, useMemo } from "react";
import Web3 from "web3";
import { getData, subscribeToEvent } from "../api/ContractDataAction";
import { useWeb3Context } from "./Web3";
import { SET, UPDATECONFIRM, UPDATEREVOKE, UPDATEEXECUTE, UPDATESUBMIT,
        Data as State } from "../actions/index";
import { dataContractReducer, INITIAL_STATE_DATA_CONTRACT } from "../reducers/DataContractReducer";

const ContextDataInitialization = createContext({
    state: INITIAL_STATE_DATA_CONTRACT,
    set: (data: State) => {},
    updateBalance: (data: any) => {},
    updateConfirm: (data: any) => {},
    updateRevoke: (data: any) => {},
    updateExecute: (data: any) => {},
    updateSubmit: (data: any) => {}
})
export function useContextDataInitialization(){
    return useContext(ContextDataInitialization);
}

interface Props{}
export const Provider: React.FC<Props> = ({children}) => {
    const [state, dispatch] = useReducer(dataContractReducer, INITIAL_STATE_DATA_CONTRACT);
    function set(data: State){
        dispatch({
            type: SET,
            data,
        })
    }
    function updateBalance(data: any){
        dispatch({
            type: SET,
            data,
        })
    }
    function updateConfirm(data: any){
        dispatch({
            type: UPDATECONFIRM,
            data
        })
    }
    function updateRevoke(data: any){
        dispatch({
            type: UPDATEREVOKE,
            data
        })
    }
    function updateExecute(data: any){
        dispatch({
            type: UPDATEEXECUTE,
            data
        })
    }
    function updateSubmit(data: any){
        dispatch({
            type: UPDATESUBMIT,
            data
        })
    }
    return(
        <ContextDataInitialization.Provider
            value={useMemo(
                () => ({
                    state,
                    set,
                    updateBalance,
                    updateConfirm,
                    updateRevoke,
                    updateExecute,
                    updateSubmit
                }),[state]
            )}
        >
            {children}
        </ContextDataInitialization.Provider>
    )
// Ta cho dữ liệu chỉ đổi khi ta state đổi. Dữ liệu đổi khi: người dùng bấm vào nút nào làm nó đổi, or tạo trans và sau khi mined thì blockchain có state mới. Ta bắt cái thứ 2 bằng subscribe event. Còn cái thứ nhất thì k xảy ra vì ta chả ấn cái gì làm cho nó đổi ngay được
}
// K cần lấy children thì k cần React.FC
export function Updater(){
    const {
        state
    } = useWeb3Context();
    const {
        state: {address},
        set,
        updateBalance,
        updateConfirm,
        updateRevoke,
        updateExecute,
        updateSubmit
    } = useContextDataInitialization();
    useEffect(() =>{ // Bất cứ khi nào có khả năng có lỗi thì đều dùng try catch
        async function get(web3: Web3, account: string) {
            try{
                const data: State = await getData(web3, account);
                console.log(data);
                set(data);
            }catch(error){
                console.log(error);
            }
        }
        if(state.web3){
            get(state.web3, state.account);
        }
        // Thật ra cú pháp này là bắt buộc. useEffect chỉ nhận hàm sync. mà ta cần gọi getData là 1 hàm async
        // (k dùng promise) thì ta phải bao nó bằng 1 hàm async và await nó nên cấu trúc trên là chặt luôn r
    },[state])
    // Biến web3 có thể coi là lưu trạng thái đăng nhập metamask v, ở đây mỗi lần web3 đổi là mọi thứ render lại hay người dùng đăng nhập vào metamask là check or đổi sang mạng khác cx check
    // Biến web3 đổi bất cứ khi nào ta dùng window.ethereum.enable, tức là ta ấn nút connect bất cứ lúc nào cx làm biến web3 đổi dù nó vẫn là chính nó -> nó ngắt cực nhanh và connect lại đó
    useEffect(() => {
        if(state.web3 && address != "0x00"){
            return subscribeToEvent(state.web3, address, (error, log) => {
                console.log("abc");
                if(error){
                    console.log(error);
                }else if(log){
                    switch (log.event){
                        case "Deposit":{
                            console.log("Log: ", log);
                            updateBalance(log.returnValues);
                            break;
                        }
                        case "ConfirmTransaction":{
                            // Kp lúc nào cx lấy mỗi giá trị in ra của event. Khi ô này xác nhận thì phải trả ra rằng ô này đã confirm r, trả ra số lượng confirmation of transaction đó cơ
                            console.log("Log: ", log);
                            const data = { 
                                // Bởi vì người khác confirm thì cái này cũng bắt nhưng kp account này confirm nên phải check điều đó
                                confirmed: state.account == log.returnValues.owner,
                                txIndex: log.returnValues.txIndex
                                // numConfirmation ta tự cộng 1, kp truyền
                            }
                            updateConfirm(data);
                            break;
                        }
                        case "RevokeConfirmation":{
                            console.log("Log: ", log);
                            const data = { 
                                confirmed: state.account == log.returnValues.owner,
                                txIndex: log.returnValues.txIndex
                            }
                            updateRevoke(data);
                            break;
                        }
                        case "ExecuteTransaction":{
                            console.log("Log: ", log);
                            const data = { 
                                txIndex: log.returnValues.txIndex
                            }
                            updateExecute(data);
                            break;
                        }
                        case "SubmitTransaction":{
                            console.log("LOG: ", log);
                            const data = {
                                ...log.returnValues,
                                value: Web3.utils.toBN(log.returnValues.value),
                            }
                            updateSubmit(data);
                            break;
                        }
                        default: 
                            console.log(log);
                    }
                }
            });
        }
    },[state.web3, address]); // Nó chỉ chạy lại nếu địa chỉ contract, web3 đổi mạng khác mà thôi vì subscribe theo account
    return null;
}