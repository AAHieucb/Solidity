import { Button, Typography, Modal, Box, CircularProgress, Badge } from "@material-ui/core";
import { useState } from "react";
import useAsync from "../utils/useAsync";
import { unlockAccount } from "../web3/web3";
import auth from "../router/auth.js";
import { useNavigate } from "react-router-dom";

const style = {
  position: 'absolute',
  top: '50%',
  left: '50%',
  transform: 'translate(-50%, -50%)',
  width: 400,
  bgcolor: '#828fdb',
  border: '2px solid #000',
  boxShadow: 24,
  p: 4,
};

function ButtonComponent(props) {
  const { onClick, loading } = props;
  return (
    <Button variant="contained" onClick={onClick} disabled={loading} fullWidth size="large">
      {loading && <CircularProgress size={14} />}
      {!loading && props.text}
    </Button>
  );
}

function Connector(props){
  const[open, setOpen] = useState(false);
  const navigate = useNavigate();
  function openModal(){
    setOpen(true);
  }
  useAsync();
  function handleClose(){
    setOpen(false);
  }
  const {pending, error, call} = useAsync(
    (callback) => unlockAccount(callback)
  );
  function callback(accountSelected, chainId){
    if(chainId){
      props.onUpdateWeb3({
        networkId: chainId
      })
    }
    if(accountSelected){
      props.onUpdateWeb3({
        account: accountSelected
      })
    }
  }
  async function connectMetamask() {
    const { error, data } = await call(callback);
    if(error){
        console.error(error);
    }
    if(data){
        // console.log(data);
        props.onUpdateWeb3({
          web3: data.web3, 
          networkId: data.networkId,
          account: data.selectedAccount
        })
        auth.login(() => {
          navigate("/content");
          // Chỉ gọi được khi render hết component này r và sau đó làm gì thì chuyển trang thì ở đây ok r
        });
    }
  }

  return(
    <div>
      <br></br>
      <div className="App">
        <Button color="primary" size="large" onClick={openModal}
            variant="contained" disableElevation>
              Connect To Your Wallet
        </Button>
      </div>
      <Modal
        open={open}
        onClose={handleClose}
      >
        <Box sx={style} style={{textAlign: "center"}}>
          <Typography variant="h5">Choose wallet</Typography>
          <br></br>
          <ButtonComponent onClick={connectMetamask} disabled={pending} loading={pending} text={"Meta Mask"}/>
        </Box>
      </Modal>
    </div>
  )
}

export default Connector;