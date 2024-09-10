pragma solidity >=0.7.0 <0.9.0;

// # Dùng transfer, send, call

// Trong vd này, ta có thể gửi ether từ address account vào contract, gửi ether từ contract vào address account
// Tuy nhiên account gửi vào contract thông qua hàm deposit, v thì contract gửi vào contract thì sao, nó k thể gọi vào 1 hàm bth đc, nên eighth sẽ dùng fallback để gửi vào contract từ contract thoải mái vói hàm transfer

// Tạo ví có các chức năng: nhận ether từ người khác, tiêu số ether đó, gửi nó cho người khác
// A deploy ứng dụng và là chủ ví (khi người dùng tải ứng dụng về, họ sẽ deploy ứng dụng lên blockchain). Những người khác sẽ gửi tiền cho A bằng hàm deposit, A sẽ tiêu bằng cách rút tiền or dùng gửi cho người khác.
// Phân biệt: wallet smart contract này là 1 loại wallet, mọi người gửi vào địa chỉ contract. Người dùng rút ra tiền về ví của mình, hay wallet tài khoản của người dùng bth, khác với wallet này => chớ nhầm ví này với tiền trong account 
contract Wallet{
    event Deposit(address sender, uint amount, uint balance);
    event Withdraw(uint amount, uint balance);
    event Transfer(address to, uint amount, uint balance);
    
    function deposit() public payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
        // msg.value là giá trị hiện tại ta set khi thực hiện tx. this là contract này, ta cast nó sang kiểu address sẽ lấy đc địa chỉ contract, mọi địa chỉ đều có balance có thể truy cập vào
    }// 1 hàm số payable mặc định sẽ là 1 hàm gửi tiền vào địa chỉ contract, khi set value ether cho địa chỉ nào đó và thực hiện giao dịch là hàm payable mặc định sẽ là gửi vào địa chỉ contract đó.
    // 1 hàm k có payable sẽ k thể nhận ether, 1 địa chỉ user account mà k convert sang payable cx k nhận ether đc
    // Kể cả constructor cx tuân theo nguyên tắc này, có payable thì có thể send ether vào contract sau khi deploy
    
    address payable public owner;
    constructor() payable{
        owner = payable(msg.sender); // Chỉ người deploy mới là chủ
        // 1 địa chỉ bth sẽ k là payable, ta chỉ gán đc 2 địa chỉ payable cho nhau nên phải convert địa chỉ kia thành payable để gán
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }
    function withdraw(uint _amount) public onlyOwner {
        owner.transfer(_amount); // Hàm built-in transfer sẽ gửi 1 lượng ether vào address payable nào đó từ địa chỉ của contract
        emit Withdraw(_amount, address(this).balance);
    } // Chú ý hàm withdraw k có payable. Chỉ cần dùng payable ở địa chỉ user có thể trao đổi ether và hàm cho phép gửi ether vào contract => contract lưu đc ether; hàm payable có thể làm bất cứ thứ gì, chỉ là thêm khả năng gửi ether vào contract với: set giá trị value-> thực hiện trans bth
    
    // Gửi cho 1 address nhận ether thì address đó cx phải là payable nên phải dùng payable ở parameter payable address có thể nhận ether; payable transaction trong contract khiến contract nhận ether
    function transfer(address payable _to, uint _amount) public onlyOwner{
        _to.transfer(_amount);
        emit Transfer(_to, _amount, address(this).balance);
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
