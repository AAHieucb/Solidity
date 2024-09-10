// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract MultisignatureWallet{
    // Để thuận tiện cho front-end => bất cứ trans nào đổi state mà state đó cần hiển thị ra thì ta tạo event cho nó
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
    
    struct Transaction{
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmation;
    }
    mapping(uint => mapping(address => bool)) public isConfirmed;
    Transaction[] public transactions;
    
    // 1 list owner cần 1 lượng chữ ký nhất định. VD 10 owner cần 8 chữ ký chẳng hạn. Vd nếu 10 owner cần cả 10 chữ ký, thế 1 ô chẳng may die hay mất tk thì cả dự án toang
    constructor(address[] memory _owners, uint _numConfirmationRequired) {
        require(_owners.length > 0, "owers required");
        require(_numConfirmationRequired > 0 && _numConfirmationRequired <= _owners.length,
                "Invalid number of required confirmation");
        for(uint i = 0; i < _owners.length; i++){
            address owner = _owners[i];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner],"Owner not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }
        numConfirmationRequired = _numConfirmationRequired;
    }
    
    modifier onlyOwner(){
        require(isOwner[msg.sender], "not owner");
        _;
    }
    function submitTransaction(address _to, uint _value, bytes memory _data) 
        public onlyOwner 
    {
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
        require(_txIndex < transactions.length,"tx does not exist");
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
        Transaction storage transaction = transactions[_txIndex];
        require(transaction.numConfirmation >= numConfirmationRequired, "not enough signature");
        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "tx failed");
        emit ExecuteTransaction(msg.sender, _txIndex);
    }
    receive () external payable{
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }
    
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
        // Chú ý ở front end nó trả ra biến object có các trường ta lấy như trong return
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
