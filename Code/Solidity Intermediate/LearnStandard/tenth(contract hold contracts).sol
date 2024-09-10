pragma solidity >=0.7.0 <0.9.0;

// # Basic / Dùng new
// Tình huống: 1 công ty sản xuất xe, mỗi khi có 1 mẫu xe mới thì sẽ tạo 1 smart contract để lưu thông tin của mẫu xe và deploy để lưu trong blockchain -> họ có thể deploy riêng biệt từng contract và lưu địa chỉ của contract trong database.
// => Cần thông tin của xe nào thì search bằng địa chỉ. Nếu có 100 xe thì phải lưu 100 contract
// 1 cách khác là dùng 1 contract để tạo ra 1 contract khác. Công ty chỉ cần địa chỉ 1 contract có transaction tạo ra contract hác mà thôi. Ta vẫn keep track được mọi contract bằng cách lưu nó trong 1 mảng để quản lý

contract Car{
    string public model;
    address public owner;
    
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    constructor(string memory _model, address _owner) payable {
        model = _model;
        owner = _owner;
    }
    // Ở đây ta giả sử có thể gửi tiền vào. Trong thực tế, các contract có thể nhận tiền thì phải có mục đích gì để sử dụng số tiền đó, nhưng ở đây chả có mục đích gì cả vì chỉ lưu thông tin
}

contract CarFactory{
    Car[] public cars ; // Kiểu biến contract cx chỉ là kiểu address thôi
    function create(string memory _model) public {
        Car car = new Car(_model, address(this)); 
        // K cần create2 assembly mà tạo được bằng new nhưng phải embed contract code vào file này
        cars.push(car);
    }
    function createAndSendEther(string memory _model) public payable{
        // 1 contract có thể đc tạo từ 1 contract khác và có thể truyền ether vào như này
        Car car = (new Car){value: msg.value}(_model, address(this));
        // Mặc định gọi vào hàm constructor -> khởi tạo và tự động deploy contract vào network
        cars.push(car);
    }
}
// Từ khóa new là từ khóa tạo ra 1 contract mới tại địa chỉ nào đó. Nếu k có new thì contract phải từng đc tạo ra tại 1 địa chỉ r. Tức là để dùng 1 contract đã có, cần:
// <tên contract>(<address contract đó>).<tên hàm muốn gọi>{value: ..., gas:...}(<params>) 
// or <instance contract>.<tên hàm muốn gọi>{value: ..., gas:...}(<params>) 
// or tạo contract: (new <tên contract>){value:...,gas:...}(<params>)
// Muốn test contract này phải chuyển lại contract về Car và search contract at address là ptu của cars remix
