import React, { useReducer, createContext, useContext, useEffect, useMemo } from "react";
import Web3 from "web3";
// Ở đây ta dùng context lưu account hiện tại và biến web3(có provider window.ethereum)
import { subscribeToAccount, subscribeToNetwork, unlockAccount } from "../api/web3";
import { INITIAL_STATE_WEB3, web3Reducer as reducer } from "../reducers/Web3Reducer";
import { UPDATE_ACCOUNT } from "../actions/index";
// Bởi vì người dùng phải unlock cái account thì biến web3 mới thực sự là kiểu Web3, còn không thì nó là vẫn là null

const Web3Context = createContext({
    state: INITIAL_STATE_WEB3,
    updateAccount: (data: { account: string; web3?: Web3}) => {},
})
export function useWeb3Context() {
    return useContext(Web3Context);
}
// useContext như ta biết là 1 cách để mọi component đều có thể gọi useContext để dùng các biến trong Context là 1 cách giảm vc truyền biến từ cha sang con của react, vc ta nhét nó thành 1 hàm thì: 
// Kể từ đây, mọi component về sau dùng useWeb3Context gán vào 1 biến thì biến đó lưu giá trị state và hàm updateAccount

interface ProviderProps {} // Để lấy children

export const Provider: React.FC<ProviderProps> = ({ children }) => {
    const [state, dispatch] = useReducer(reducer, INITIAL_STATE_WEB3);

    function updateAccount(data: { account: string; web3?: Web3; netId?: number }) {
        dispatch({
            type: UPDATE_ACCOUNT,
            ...data,
        });
    }

    return (
        <Web3Context.Provider
            value={useMemo(
                () => ({
                    state,
                    updateAccount
                }),[state])}
        >
            {children}
        </Web3Context.Provider>
    );
};

export function Updater() {
    const { state, updateAccount } = useWeb3Context();

    async function test(){
        try{
            const data = await unlockAccount();
            if(data){
                updateAccount(data);
            }
        }catch(error){
            console.log(error)
        }
    }

    useEffect(() => {
        if (state.web3) {
            // Ở đây mỗi lần ta ấn connect(khi đã connect) thì nó sẽ render lại các component cập nhập số liệu mới nhất là vì ấn vào gọi ethereum.enable làm đổi biến web3(vẫn là v) làm cho các component nào có useEffect gọi vào biến web3 đều render lại nên cập nhập lại(kp reload) -> nên ta có thể dùng nó để update dữ liệu mới nhất bằng cách ấn vào nút connect đó
            const unsubscribe = subscribeToAccount(state.web3, (error, account) => {
                if (error) {
                    console.error(error);
                }
                if (account !== undefined && account !== state.account) {
                    // window.location.reload(); // Đổi tài khoản khác thì reload trang để cập nhập
                    test();
                }
            });

            return unsubscribe;
        }
    }, [state.web3, state.account]);
    useEffect(() => {
        if(state.web3){
            const unsubscribe = subscribeToNetwork(state.web3, (error, netId) => {
                if (error) {
                    console.error(error);
                }
                if (netId !== undefined && netId !== state.netId) {
                    window.location.reload(); // Đổi tài khoản khác thì reload trang để cập nhập
                    // Ta k thể render lại cả mạng được vì các thứ ta dùng ta chỉ cho đổi khi web3, account đổi chứ netId đổi thì nó k render lại vì mỗi mạng nó rất khác, k thể như v đc
                }
            });
            return unsubscribe;
        }
    },[state.web3, state.netId])

    return null;
}