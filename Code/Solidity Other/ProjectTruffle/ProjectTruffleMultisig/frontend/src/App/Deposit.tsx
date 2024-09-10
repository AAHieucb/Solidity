import { Button } from "semantic-ui-react";
import { useWeb3Context } from "../contexts/Web3";
import useAsync from "../utils/useAsync";
import { depositContract } from "../api/ContractDataAction";
import { useState } from "react";
import Web3 from "web3";
import BN from "bn.js";

interface DepositParam{
    web3: Web3,
    account: string,
    value: BN
}

function Deposit() {
    const {
        state: { web3, account }
    } = useWeb3Context();
    const [input, setInput] = useState("");

    const { pending, call } = useAsync<DepositParam, void>(
        ({web3, account, value}) => depositContract(web3, account, value)
    );
    async function deposit() {
        if(web3){
            // Trong typesccript nó kiểm tra type rất chặt, nên phải có check web3 ở đây tránh Th nó null báo lỗi
            const value = Web3.utils.toBN(input); // Dùng BN có sẵn trong Web3
            if(value.gt(Web3.utils.toBN(0))){
                const {error} = await call({ web3, account, value} )
                if(error)
                    console.log(error);
                else{
                    setInput("");
                    // K gọi được window.ethereum ở đây mà chỉ gọi được trong file ts
                    // Để balanceUpdate ta k thể gọi ở đây được mà phải subcribe event, ta muốn là k chỉ người này dùng mà những người khac gửi tiền vào contract thì người này cx thấy số dư contract tăng cơ
                }
            }
        }
    }
    function onChange(e: React.ChangeEvent<HTMLInputElement>) {
        setInput(e.target.value);
    }
    return (
        <div>
            <div className="ui input focus" style={{width: "100%"}}>
                <input type="text" placeholder="Deposit in wei" value={input} 
                    onChange={onChange}/>
                <Button color="green" onClick={() => deposit()} 
                    disabled={pending} loading={pending}>Deposit</Button>
            </div>
        </div>
    )
}
export default Deposit;