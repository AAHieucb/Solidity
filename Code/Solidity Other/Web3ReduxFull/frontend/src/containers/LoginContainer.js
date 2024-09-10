import Login from "../components/Login";
import { connect } from "react-redux";

const mapStateToProps = (state) => {
    const address = state.Web3Reducer.account;
    const web3 = state.Web3Reducer.web3;
    const netId = state.Web3Reducer.netId;
    return{
        address, web3, netId
    }
}
export default connect(mapStateToProps, null)(Login);