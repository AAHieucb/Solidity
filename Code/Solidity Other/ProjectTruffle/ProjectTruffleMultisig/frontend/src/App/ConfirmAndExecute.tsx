import { Button } from "semantic-ui-react";
import { useWeb3Context } from "../contexts/Web3";
import useAsync from "../utils/useAsync";
import Web3 from "web3";
import { useContextDataInitialization } from "../contexts/ContractData";
import { confirmTrans, executeTrans, revokeTrans } from "../api/ContractDataAction";

interface Params{
    web3: Web3,
    account: string,
    txIndex: number
}

//@ts-ignore
function ConfirmRevokeAndExecute(data){
    const {
        state: {web3, account}  
    } = useWeb3Context()
    const {
        state
    } = useContextDataInitialization();
    // Ta nên truyền từ mẹ sang con ở TH này vì nếu trong này nó truy cập vào transaction hiện tại thông qua index sẽ rất phức tạp, hãy lấy từ mẹ
    const confirmTransaction = useAsync<Params, void>(
        ({web3, account, txIndex}) => confirmTrans(web3, account, txIndex)
        // Đầu vào phải là kiểu Params là 1 object đúng interface đã khai báo
    );
    const executeTransaction = useAsync<Params, void>(
        ({web3, account, txIndex}) => executeTrans(web3, account, txIndex)
    );
    const revokeTransaction = useAsync<Params, void>(
        ({web3, account, txIndex}) => revokeTrans(web3, account, txIndex)
    );
    async function confirm(){
        if(web3){
            const {error} = await confirmTransaction.call({web3, account, txIndex: data.index});
            if(error){
                console.log(error);
            }
        }
    }
    async function revoke(){
        if(web3){
            const {error} = await revokeTransaction.call({web3, account, txIndex: data.index});
            if(error){
                console.log(error);
            }
        }
    }
    async function execute(){
        if(web3){
            const {error} = await executeTransaction.call({web3, account, txIndex: data.index});
            if(error){
                console.log(error);
            }
        }
    }
    return(
        <div>
            <Button
                onClick={confirm}
                loading={confirmTransaction.pending}
                disabled={confirmTransaction.pending || data.executed || data.confirmed}
            >
                Confirm
            </Button>
            <Button 
                onClick={revoke}
                loading={revokeTransaction.pending}
                disabled={revokeTransaction.pending || data.executed || !data.confirmed}
            >
                Revoke
            </Button>
            {data.numberOfConfirmation >= state.numConfirmationRequired && !data.executed 
                ? <Button
                    onClick={execute}
                    loading={executeTransaction.pending}
                    disabled={executeTransaction.pending}
                >
                    Execute
                </Button> 
                : null
            }
        </div>
    )
}
export default ConfirmRevokeAndExecute;
