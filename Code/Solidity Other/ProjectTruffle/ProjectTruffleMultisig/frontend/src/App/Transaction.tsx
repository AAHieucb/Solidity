import { Button } from "semantic-ui-react";
import { useState, Fragment } from "react";
import { useContextDataInitialization } from "../contexts/ContractData";
import ModalTrans from "./Modal";
import ConfirmRevokeAndExecute from "./ConfirmAndExecute";

function Transaction(){
    const {
        state
    } = useContextDataInitialization();
    const [openModal, setOpenModal] = useState(false);
    var transactionList = state.transactions.map((transaction, index) => {
        return(
            <li key={index}>
                <div>Send To: {transaction.to}</div>
                <div>Amount of Ether: {transaction.value.toNumber()}</div>
                <div>Data: {transaction.data}</div>
                <div>Executed: {transaction.executed ? "Yes" : "No"}</div>
                <div>Current number of confirmation: {transaction.numComfirmation}</div>
                {
                    transaction.isConfirmedByCurrentAccount 
                    ? "You have confirmed this transaction" 
                    : "You haven't confirm this transaction"
                }
                <ConfirmRevokeAndExecute 
                    index={transaction.txIndex} 
                    confirmed={transaction.isConfirmedByCurrentAccount}
                    executed={transaction.executed} 
                    numberOfConfirmation={transaction.numComfirmation}
                ></ConfirmRevokeAndExecute>
            </li>
        )
    })
    return(
        <Fragment>
            <b>Transaction({state.transactionCount})</b>
            <br></br>
            <Button color="green"
                onClick={() => setOpenModal(true)}
            >
                Create Transaction
            </Button>
            {/* Modal ta cx có trong bootstrap, lib modal riêng, or senmatic ui cũng có */}
            <ModalTrans open={openModal} onClose={() => setOpenModal(false)}></ModalTrans>
            <ul>
                {transactionList}
            </ul>
        </Fragment>
    )
}

export default Transaction;