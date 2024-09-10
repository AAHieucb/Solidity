function Network(data: any){ // Cứ gom tất cả vào type any r lấy bên trong type gì ra
    function getNetwork(netId: number) {
        switch (netId) {
            case 1:
                return "Mainnet";
            case 2:
                return "Morden test network";
            case 3:
                return "Ropsten network";
            case 4:
                return "Rinkeby test network";
            case 42:
                return "Kovan test network";
            default:
                return "Local network";
        }
    }
    return (
        <div>Network: {getNetwork(data.netId)}</div>
    )
}
export default Network;
