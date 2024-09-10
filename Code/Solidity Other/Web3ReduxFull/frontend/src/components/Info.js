import { Button, Typography, Modal, Box, TextField, CircularProgress, Card, CardMedia,
CardContent, CardActions, CardHeader } from "@material-ui/core";
import { useEffect, useState } from "react";
import useAsync from "../utils/useAsync";
import Web3 from "web3";
import { getInfo, subscribeToEvents, updateData } from "../web3/userAction";
import LoginContainer from "../containers/LoginContainer";

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
        <Button onClick={onClick} disabled={loading} variant="contained" size="large" color="secondary"
        style={{width: "100%"}}>
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

function Info(props){
    const [dataState, setData] = useState({
        age: 0,
        avatar: "",
        description: "",
        id: 0,
        name: ""
    })
    const[dataUpdate, setDataUpdate] = useState(dataState);
    const getInfoAsync = useAsync(
        ({web3, address, netId}) => getInfo(web3, address, netId)
    );
    useEffect(() => {
        async function getData(){
            if(props.web3 && (props.netId == 3 || props.netId == 4)){
                const {error, data} = await getInfoAsync.call({web3: props.web3, address: props.address,
                    netId: props.netId});
                if(error){
                    console.log(error);
                }
                if(data){
                    if(data.id != 0){
                        setData({
                            age: data.age,
                            avatar: data.avatar,
                            description: data.description,
                            id: data.id,
                            name: data.name
                        })
                    } else {
                        // Chú ý maximum depth trong useEffect gọi lại setState thì nó re-render mãi
                        // Chỉ setState khi có điều kiện như này để đảm bảo chỉ render 1 lần. Cái useEffect nó fix lỗi này của class bằng cách setState trùng thì nó sẽ k render lần sau nhưng thưc ra nó vẫn render dôi 1 lần nên phải như này mới tối ưu
                        setData({
                            age: 0,
                            avatar: "",
                            description: "",
                            id: 0,
                            name: ""
                        })
                    }
                }
            }
        }
        getData();
    },[props.web3, props.address, props.netId]);
    useEffect(() => {
        if(props.web3 && props.address != "0x00" && (props.netId == 3 || props.netId == 4)){
            return subscribeToEvents(props.web3, props.address, (log) => {
                if(log){
                    setData({
                        age: log.returnValues.age,
                        avatar: log.returnValues.avatar,
                        description: log.returnValues.description,
                        id: log.returnValues.id,
                        name: log.returnValues.name
                    });
                    setDataUpdate({
                        age: log.returnValues.age,
                        avatar: log.returnValues.avatar,
                        description: log.returnValues.description,
                        id: log.returnValues.id,
                        name: log.returnValues.name
                    })
                    // Chỗ này ta setDataUpdate(data) là sai vì đúng là ta gọi setData bên trên nhưng nó k có cập nhập ngay nhé mà gọi lại hàm để cập nhập nên kp cứ set xong là có và dùng ngay bên dưới nhé
                    // Nếu dùng thì dataUpdate vẫn sẽ là rỗng vì ta set cho data mà data chưa được gán. Ở đây bắt buộc gán thế này 
                }
            }, props.netId);
        }
    }, [props.web3, props.address, props.netId]);

    const [open, setOpen] = useState(false);
    function handleClose(){
        setOpen(false);
    }
    const updateDataAsync = useAsync(
        ({web3, address, info, netId}) => updateData(web3, address, info, netId)
    );
    async function update(e){
        e.preventDefault();
        if(props.web3){
            const info = {
                age: Web3.utils.toBN(dataUpdate.age),
                avatar: dataUpdate.avatar,
                name: dataUpdate.name,
                description: dataUpdate.description
            }
            const {error} = await updateDataAsync.call({web3: props.web3, address: props.address, info,
                netId: props.netId});
            if(error){
                console.log(error);
            }
        }
    }
    function openModal(){
        setOpen(true);
        setDataUpdate(dataState);
    }
    function handleChange(e){
        setDataUpdate({
            ...dataUpdate,
            [e.target.name]: e.target.value
        })
    }
    // Thực tế có thể gom hàm update và add ở front end vào làm 1, vì hiện như nhau mà xong check xem id 2 gửi vào là gì mà gọi update hay add để gom vào 1 component sẽ tốt hơn. Ở đây chót tách 2 r thì thôi k làm lại nx

    // uncomment this when use in ropstent or rinkeby
    if(props.netId !=  3 && props.netId != 4){
        return(
            <Typography variant="h5" style={{color: "white", textAlign: "center"}}>
                    No Data in this network
            </Typography>
        )
    }

    const validate = () => {
        if(dataUpdate.age > 5 && dataUpdate.age < 100){
            return true;
        }
        else{
            return false;
        }
    }
    
    return(
        <div>
            {
                dataState.id == 0 ? 
                <Typography variant="h5" style={{color: "white", textAlign: "center"}}>
                    You haven't in the game, please add your data
                </Typography>
                :<div>
                    <Card variant="outlined" style={{width: "50%", marginLeft: "25%"}}>
                        <CardHeader 
                            title="Your data"
                            style={{textAlign: "center"}}
                        >
                        </CardHeader>
                        <CardMedia
                            component="img"
                            height="140"
                            image={`https://picsum.photos/300/140`}
                            alt="Your avatar cannot load"
                        />
                        <CardContent>
                            <Typography gutterBottom variant="h5" component="div" 
                                style={{textAlign: "center"}}
                            >{dataState.name}</Typography>
                            {/* <Typography variant="body2" color="text.secondary">Avatar: {dataState.avatar}</Typography> */}
                            <Typography variant="body2" color="text.secondary">Age: {dataState.age}</Typography>
                            <Typography variant="body2" color="text.secondary">Description: {dataState.description}</Typography>
                        </CardContent>
                        <CardActions>
                            <ButtonComponentUpdate 
                                onClick={() => openModal()}
                                loading={updateDataAsync.pending}
                                text={"Update"}
                                disabled={updateDataAsync.pending}
                            ></ButtonComponentUpdate>
                        </CardActions>
                    </Card>
                    <br></br>
                </div>
            }
            <Modal
                open={open}
                onClose={handleClose}
            >
                <Box sx={style}>
                    <form onSubmit={update}>
                        <TextField 
                            required
                            color={validate() ? "primary" : "secondary"}
                            variant="filled"
                            type="number"
                            label="Age:"
                            placeholder="18"
                            width="fit-content"
                            fullWidth
                            value={dataUpdate.age}
                            onChange={handleChange}
                            name="age"
                            helperText={validate() ? "Great" : "Your actual age"}
                        />
                        <TextField 
                            required
                            color={dataUpdate.avatar != "" ? "primary" : "secondary"}
                            variant="filled"
                            type="text"
                            label="Avatar:"
                            placeholder="http"
                            fullWidth
                            value={dataUpdate.avatar}
                            name="avatar"
                            onChange={handleChange}
                            helperText={dataUpdate.avatar != "" ? "Great" : "This can be anything"}
                        />
                        <TextField 
                            required
                            color={dataUpdate.name.length >= 2 ? "primary" : "secondary"}
                            variant="filled"
                            type="text"
                            label="Name:"
                            placeholder="Your name"
                            fullWidth 
                            value={dataUpdate.name}
                            name="name"
                            onChange={handleChange}
                            helperText={dataUpdate.name.length >= 2 ? "Great" : ""}
                        />
                        <TextField 
                            required
                            color={dataUpdate.description.length >= 2 ? "primary" : "secondary"}
                            variant="filled"
                            type="text"
                            label="Description:"
                            multiline
                            fullWidth 
                            value={dataUpdate.description}
                            name="description"
                            onChange={handleChange}
                            helperText={dataUpdate.description.length >= 2 ? "Great" : "Short description"}
                            placeholder="Multiline description"
                        />
                        <div style={{height: "10px"}}></div>
                        <ButtonComponentUpdate2 
                            loading={updateDataAsync.pending}
                            text={"Update Data"}
                            disabled={updateDataAsync.pending}
                            type={"submit"}
                            style={dataUpdate.name.length >= 2 && dataUpdate.description.length >= 2 &&
                                dataUpdate.avatar != "" && validate() ? "contained" : "outlined"}
                        ></ButtonComponentUpdate2>
                        {
                            (dataUpdate.description.length >= 1 || dataUpdate.name.length != "" || 
                            dataUpdate.avatar != "" || dataUpdate.age != "") ? 
                            <Button variant="standard" style={{float: "right"}} onClick={() => {
                                setDataUpdate({
                                    ...dataUpdate,
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
            {
                dataState.id == 0 ? <LoginContainer></LoginContainer> : null
            }
        </div>
    )
}

export default Info;