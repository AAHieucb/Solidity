// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

// # Basic / Create multisig wallet

// Cũng chỉ là cần nhiều chữ ký để làm gì đó: gọi 1 contract khác là chuyển tiền cho ai
contract MultisignatureWallet{
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);
    
    address[] public owners;
    uint public numConfirmationRequired;
    mapping(address=>bool) public isOwner;
    
    // Trong struct k được dùng mapping vì k khởi tạo đc
    struct Transaction{
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmation;
    }
    // Cách đặt biến có thể check được địa chỉ nào đã confirm trans này chưa
    mapping(uint => mapping(address => bool)) public isConfirmed;
    Transaction[] public transactions;
    
    constructor(address[] memory _owners, uint _numConfirmationRequired) {
        require(_owners.length > 0, "owers required");
        require(_numConfirmationRequired > 0 && _numConfirmationRequired <= _owners.length,
                "Invalid number of required confirmation");
        for(uint i = 0; i < _owners.length; i++){
            address owner = _owners[i]; // Check owner phải tồn tại
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner],"Owner not unique"); // Check owner k bị trùng nhau. Lưu để kp thêm vòng loop
            isOwner[owner] = true;
            owners.push(owner);
        }
        numConfirmationRequired = _numConfirmationRequired;
    }
    
    modifier onlyOwner(){
        require(isOwner[msg.sender], "not owner");
        _;
    }
    
    // Cái data truyền vào hàm là kiểu bytes và ta gọi hàm đó về sau tức là ta truyền vào cho nó 1 abi.encodeWithSignature để nó gọi vào hàm nào đó. Nếu k thì phải truyền bytes bất kỳ thì phải đúng form "0x00","0xaa" or "0xff" k được truyền 0x0 là sai luôn
    function submitTransaction(address _to, uint _value, bytes memory _data) 
        public onlyOwner 
    {
        // Lưu id của trans là số lượng trans hiện tại luôn
        uint txIndex = transactions.length;
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numConfirmation: 0
        }));
        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }
    modifier txExist(uint _txIndex){
        require(_txIndex < transactions.length, "tx does not exist");
        _;
    }
    modifier notExecuted(uint _txIndex){
        require(transactions[_txIndex].executed == false, "tx already executed");
        _;
    }
    modifier notConfirmed(uint _txIndex){
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }
    function confirmTransaction(uint _txIndex) 
        public onlyOwner txExist(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        isConfirmed[_txIndex][msg.sender] = true;
        transaction.numConfirmation += 1;
        emit ConfirmTransaction(msg.sender, _txIndex);
    }
    function executeTransaction(uint _txIndex)
        public
        onlyOwner
        txExist(_txIndex)
        notExecuted(_txIndex)
    {
        // Check cả số dư nx chứ nhỉ
        Transaction storage transaction = transactions[_txIndex];
        require(transaction.numConfirmation >= numConfirmationRequired, "not enough signature");
        transaction.executed = true; // Cản reentrancy r, gọi phát nx sẽ bị cản bởi modifier. Đầu tiên phải deposit vào trans này, sau đó gọi hàm này để call chuyển tiền từ contract này sang địa chỉ ng nhận
        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        // Để gọi 1 contract khác thì phải biết địa chỉ của contract đó và tên hàm đó(or bytes của nó encodeWithSignature để call)
        require(success, "tx failed");
        emit ExecuteTransaction(msg.sender, _txIndex);
    }
    receive () external payable{ // Hàm này để nhận tiền log ra
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }
    // Ở phiên bản cũ chỉ dùng 1 fallback function. Bh nó tách ra làm 2 hàm. 1 là fallback(), 2 là receive() receive được gọi khi calldata () là empty bất kể có ether hay k. Còn fallback được gọi khi k có function nào match cả -> nếu k khai báo receive thì nó vẫn gọi vào fallback mà thôi nhưng sẽ throw warning
    // Còn fallback nếu mà k có payable thì công dụng tương tự nhưng k được gọi khi truyền vào ether => Tức 1 cái là call() empty hoàn toàn còn 1 cái là call với tham số k empty và k match hàm nào cả

    // Helper function
    function deposit() payable external{
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }
    function revokeConfirmation(uint _txIndex) public txExist(_txIndex) onlyOwner notExecuted(_txIndex){
        Transaction storage transaction = transactions[_txIndex];
        require(isConfirmed[_txIndex][msg.sender], "Haven't confirmed yet");
        transaction.numConfirmation -= 1;
        isConfirmed[_txIndex][msg.sender] = false;
        emit RevokeConfirmation(msg.sender, _txIndex);
    }
    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }
    function getTransaction(uint _txIndex) public view
        returns (address to, uint value, bytes memory data, bool executed, uint numConfirmations){
        Transaction storage transaction = transactions[_txIndex];
        return (transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmation);
    }
    function getOwners() public view returns (address[] memory) {
        return owners;
    }
}

// Test multisign để gọi 1 contract khác.
contract TestContract {
    uint public i;

    function callMe(uint j) public {
        i += j;
    }

    function getData() public pure returns (bytes memory) {
        return abi.encodeWithSignature("callMe(uint256)", 123);
    }
}
