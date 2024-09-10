import { Button, Typography, Modal, Box, TextField, CircularProgress } from "@material-ui/core";
import { addData } from "../web3/userAction";
import { useState } from "react";
import useAsync from "../utils/useAsync";
import Web3 from "web3";

const style = {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    width: 400,
    bgcolor: '#caf3e5',
    border: '2px solid #000',
    boxShadow: 24,
    p: 4,
};

function ButtonComponentUpdate(props) {
    const { onClick, loading } = props;
    return (
        <Button onClick={onClick} disabled={loading}  variant="contained" size="large" color="secondary">
            {loading && <div><CircularProgress size={14} /><span> Mining...</span></div>}
            {!loading && props.text}
        </Button>
    );
}
function ButtonComponentUpdate2(props) {
    const { loading, type, style } = props;
    return (
        <Button disabled={loading} variant={style} style={{float: "right"}} 
            color="secondary" type={type}
        >
            {loading && <div><CircularProgress size={14} /><span> Mining...</span></div>}
            {!loading && props.text}
        </Button>
    );
}

function Login(props){
    const [open, setOpen] = useState(false);
    function handleClose(){
        setOpen(false);
    }
    const [data, setData] = useState({
        age: "",
        avatar: "",
        description: "",
        name: "",
        id: 0
    })
    const setDataAsync = useAsync(
        ({web3, address, info, netId}) => addData(web3, address, info, netId)
    );
    async function login(e){
        e.preventDefault();
        if(data.name != "" && data.age > 5 && data.age < 100 && data.avatar != ""){
            if(props.web3){
                const info = {
                    age: Web3.utils.toBN(data.age),
                    avatar: data.avatar,
                    name: data.name,
                    description: data.description
                }
                // vl call nó chỉ dừng sau khi trans được mine chứ éo phải là bắt event
                const {error} = await setDataAsync.call({web3: props.web3, address: props.address, info,
                    netId: props.netId});
                if(error){
                    console.log(error);
                }else{
                    setData({
                        age: "",
                        avatar: "",
                        description: "",
                        name: "",
                        id: 0
                    })
                }
            }
        }
    }
    function openModal(){
        setOpen(true);
    }
    function handleChange(e){
        setData({
            ...data,
            [e.target.name]: e.target.value
        })
    }

    const validate = () => {
        if(data.age > 5 && data.age < 100){
            return true;
        }
        else{
            return false;
        }
    }

    //Nếu dự án lớn thì tạo thêm reducer update phần data của người hiện tại nữa chứ như này khó
    return(
        <div>
            <br></br>
            {
                <div>
                    <div className="App">
                        <ButtonComponentUpdate 
                            onClick={() => openModal()}
                            loading={setDataAsync.pending}
                            text={"Add New Data"}
                            disabled={setDataAsync.pending}
                        >
                        </ButtonComponentUpdate>
                    </div>
                    <Modal
                        open={open}
                        onClose={handleClose}
                    >
                        <Box sx={style}>
                            <form onSubmit={login} autocomplete="off">
                                <TextField 
                                    required
                                    color={validate() ? "primary" : "secondary"}
                                    variant="filled"
                                    type="number"
                                    label="Age:"
                                    placeholder="18"
                                    width="fit-content"
                                    fullWidth
                                    value={data.age}
                                    onChange={handleChange}
                                    name="age"
                                    helperText={validate() ? "Great" : "Your actual age"}
                                />
                                <TextField 
                                    required
                                    color={data.avatar != "" ? "primary" : "secondary"}
                                    variant="filled"
                                    type="text"
                                    label="Avatar:"
                                    placeholder="http"
                                    fullWidth
                                    value={data.avatar}
                                    name="avatar"
                                    onChange={handleChange}
                                    helperText={data.avatar != "" ? "Great" : "This can be anything"}
                                />
                                <TextField 
                                    autocomplete="off"
                                    required
                                    color={data.name.length >= 2 ? "primary" : "secondary"}
                                    variant="filled"
                                    type="text"
                                    label="Name:"
                                    placeholder="Your name"
                                    fullWidth 
                                    value={data.name}
                                    name="name"
                                    onChange={handleChange}
                                    helperText={data.name.length >= 2 ? "Great" : ""}
                                />
                                <TextField 
                                    required
                                    color={data.description.length >= 2 ? "primary" : "secondary"}
                                    variant="filled"
                                    type="text"
                                    label="Description:"
                                    multiline
                                    fullWidth 
                                    value={data.description}
                                    name="description"
                                    onChange={handleChange}
                                    helperText={data.description.length >= 2 ? "Great" : "Short description"}
                                    placeholder="Multiline description"
                                />
                                <div style={{height: "10px"}}></div>
                                <ButtonComponentUpdate2
                                    loading={setDataAsync.pending}
                                    text={"Add Data"}
                                    disabled={setDataAsync.pending}
                                    type={"submit"}
                                    style={data.description.length >= 2 && data.name.length >= 2 && 
                                        data.avatar != "" && validate() ? "contained" : "outlined"}
                                >
                                </ButtonComponentUpdate2>
                                {
                                    (data.description.length >= 1 || data.name.length != "" || data.avatar != ""
                                    || data.age != "") ? 
                                    <Button variant="standard" style={{float: "right"}} onClick={() => {
                                        setData({
                                            ...data,
                                            age: "",
                                            avatar: "",
                                            description: "",
                                            name: ""
                                        })
                                    }}>Clear</Button>
                                    : null
                                }
                            </form>
                        </Box>
                    </Modal>
                </div>
            }
        </div>
    )
}

export default Login;