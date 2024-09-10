import Data from "../App/Data";
import { Fragment } from "react";
import TransactionAction from "./TransactionAction";

function Contract(){
    return(
        <Fragment>
            <Data></Data>
            <div style={{height: 10}}></div>
            <TransactionAction></TransactionAction>
        </Fragment>
    )
}
export default Contract;