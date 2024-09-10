import Deposit from "../App/Deposit";
import Transaction from "../App/Transaction";
import { Fragment } from "react";

function TransactionAction(){
    return(
        <Fragment>
            <Deposit></Deposit>
            <div style={{height: 10}}></div>
            <Transaction></Transaction>
        </Fragment>
    )
}
export default TransactionAction;