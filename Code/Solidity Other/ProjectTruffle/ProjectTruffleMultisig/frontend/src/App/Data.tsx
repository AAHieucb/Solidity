import { useContextDataInitialization } from "../contexts/ContractData";

function Data() {
    const {
        state
    } = useContextDataInitialization();
    var ownerList = state.owners.map((owner, index) => {
        return(
            <li key={index}>{owner}</li>
        )
    })
    return (
        <div>
            <div>Contract Address: {state.address}</div>
            <div>Owner: </div>
            <ul>
                {ownerList}
            </ul>
            <div>Number of transaction: {state.transactionCount}</div>
            <div>Number of confirmation required: {state.numConfirmationRequired}</div>
            <b>Balance: {state.balance}</b>
        </div>
    )
}
export default Data;