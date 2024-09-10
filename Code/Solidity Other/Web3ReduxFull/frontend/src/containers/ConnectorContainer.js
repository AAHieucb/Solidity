import Connector from "../components/Connector";
import { connect } from "react-redux";
import { updateWeb3 } from "../actions/index"

const mapDispatchToProps = (dispatch) => {
    return {
        onUpdateWeb3: (data) => {
            dispatch(updateWeb3(data));
        }
    }
}
export default connect(null, mapDispatchToProps)(Connector);