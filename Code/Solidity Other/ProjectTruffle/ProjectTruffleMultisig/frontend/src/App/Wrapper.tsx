import Network from "../App/Network";
import { Fragment } from "react";
import { Message, Button } from "semantic-ui-react";
import { useWeb3Context } from "../contexts/Web3";
import useAsync from "../utils/useAsync";
import { unlockAccount } from "../api/web3";
import Contract from "./Contract";

// Để hiển thị ra ta sẽ dùng react context để lưu web3 và account hiện tại để dùng 2 data này hiển thị ra cũng chỉ là 1 cách lưu để truyền cho các component đã học trong react, ở đây ta k dùng redux nên dùng context cho dễ
function Wrapper(){
    const {
        state: { account, netId },
        updateAccount
    } = useWeb3Context();
    const { pending, error, call } = useAsync(unlockAccount);
    async function onCLickConnect() {
        const { error, data } = await call(null);
        if(error){
            console.error(error);
        }
        if(data){
            updateAccount(data);
        }
    }
    return(
        <Fragment>
            {account == "0x00" ? null : <Network netId={netId}></Network>}
            <div>Account: {account}</div>
            {account == "0x00" ? <Message warning>Metamask is not connected</Message> : null}
            <Button 
                color="green"
                onClick={() => onCLickConnect()}
                disabled={pending}
                loading={pending} // ĐM trong sematic-ui thì button có sẵn loading
            >
                Connect to Metamask
            </Button>
            <div style={{height: 10}}></div>
            {account == "0x00" ? null : <Contract></Contract>}
        </Fragment>
    )
}
export default Wrapper;
