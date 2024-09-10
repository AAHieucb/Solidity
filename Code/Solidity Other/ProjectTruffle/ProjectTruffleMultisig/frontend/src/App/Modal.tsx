import { Label, Button, Input, Modal, Form } from "semantic-ui-react";
import { useWeb3Context } from "../contexts/Web3";
import useAsync from "../utils/useAsync";
import { useState, Fragment } from "react";
import Web3 from "web3";
import BN from "bn.js";
import { useContextDataInitialization } from "../contexts/ContractData";
import { createTransaction } from "../api/ContractDataAction";

interface CreateTransParam{
    web3: Web3,
    account: string,
    to: string,
    value: BN,
    dataT: string
}

//@ts-ignore
function ModalTrans({ open, onClose }){
    const [to, setTo] = useState("");
    const [value, setValue] = useState("");
    const [dataT, setData] = useState("");
    const {
        state: { web3, account } // Chú ý bên trong context web3 nằm trong 1 state nhé
    } = useWeb3Context();
    const { pending, call } = useAsync<CreateTransParam, void>(
        ({web3, account, to, value, dataT}) => createTransaction(web3, account, { to, value, dataT})
    );
    async function submitTrans(){
        if(web3){
            const { error} =  await call({ web3, account, to, value: web3.utils.toBN(value), dataT});
            // Phải đúng cả tên trong interface nhé
            if(error){
                console.log(error);
            }else{
                setTo("");
                setValue("");
                setData("");
            }
        }
    }
    return(
        <Modal open={open} onClose={onClose}>
            <Modal.Header>Create Transaction</Modal.Header>
            <Modal.Content>
                <Form>
                    <Form.Field>
                        <Label pointing="left">TO: </Label>
                        <Form.Input
                            type="text"
                            placeholder="Address to send to"
                            value={to}
                            onChange={(e) => { setTo(e.target.value) }}
                        ></Form.Input>
                    </Form.Field>
                    <Form.Field>
                        <Label pointing="left">VALUE: </Label>
                        <Form.Input
                            type="text"
                            placeholder="Amount in ether"
                            value={value}
                            onChange={(e) => { setValue(e.target.value) }}
                        ></Form.Input>
                    </Form.Field>
                    <Form.Field>
                        <Label pointing="left">DATA: </Label>
                        <Form.Input
                            type="text"
                            placeholder="Data, example: 0x00"
                            value={dataT}
                            onChange={(e) => { setData(e.target.value) }}
                        ></Form.Input>
                    </Form.Field>
                </Form>
            </Modal.Content>
            <Modal.Actions>
                <Button onClick={onClose} disabled={pending}>
                    Cancel
                </Button>
                <Button
                    color="green"
                    onClick={submitTrans}
                    disabled={pending}
                    loading={pending}
                >
                    Create
                </Button>
            </Modal.Actions>
        </Modal>
    )
}
export default ModalTrans;