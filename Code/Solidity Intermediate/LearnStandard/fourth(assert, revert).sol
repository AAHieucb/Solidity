pragma solidity >=0.7.0 <0.9.0;

// # Event
contract Fourth{
    event indexedEvent(address indexed addr, string mess);
    event Log();
    function testEvent() public {
        emit indexedEvent(msg.sender, "Hello World");
        emit Log();
    }
    // Event cũng là 1 cách rẻ để lưu data trong transaction của blockchain thông qua gửi mess như này
    // Từ khóa indexed trong địa chỉ truyền vào event khiến cho event đó gắn với 1 địa chỉ nào đó, vd ta dùng địa chỉ là msg.sender như trên thì ta có thể search event theo địa chỉ được.
    // VD k có indexed: A,B,C cùng thực hiện transaction, mỗi người emit 1 cái event vào blockchain. Người dùng muốn lấy tất cả event của A gửi -> họ có thể request đến full node của blockchain r yêu cầu mọi event r thực hiện search trong các event có trường địa chỉ trùng với A
    // VD dùng indexed gắn với 1 địa chỉ là đối số truyền vào event -> ta có thể dễ dàng truy cập đến 1 event nào có địa chỉ (chứa indexed) nào trực tiếp luôn => Bất cứ khi nào dùng địa chỉ trong event đều nên dùng indexed, sau này truy cập nó rất dễ với web3
    
    // # Basic / Dùng require, assert
    uint public balance;
    uint public constant MAX_UINT = 2**256 - 1; // Từ khóa constant chỉ nên dùng kiểu như này
    function deposit(uint _amount) public {
        // require kiểm tra điều kiện, k thỏa mãn sẽ fail, undone, trả ra message
        // Tránh lỗi overflow, kiểm tra để đảm bảo assert k bị sai
        uint oldBalance = balance;
        uint newBalance = balance + _amount;

        // require(newBalance >= oldBalance, "Overflow");
        balance += newBalance;
        assert(balance >= oldBalance);
        // assert sẽ throw ra error, assert ít dùng, đk của assert khi dùng phải luôn expected được thỏa mãn
        // assert sẽ dùng hết gas còn lại và giao dịch được undone
        // Ở TH này muốn balance phải thỏa mãn điều kiện nên dùng assert và ta phải viết code sao cho assert luôn đúng. Thế nếu đúng thì còn viết làm gì nx? => đương nhiên là ta expected là luôn đúng nhưng hacker có thể mò bằng cách gì đó vượt qua rào cản require và thật éo le là code nó chạy được để hack tiền thì khi đó assert sẽ cản lại
    }
    function withdraw(uint _amount) public {
        uint oldBalance = balance;
        if(balance < _amount){
            revert("Underflow");//revert chỉ có 1 đối số và dừng Ct nên dùng trong các câu điều kiện
            //chỉ dùng revert khi cần check các điều kiện phức tạp if else lồng nhau
            //k dùng đc require. Ở đây đảm bảo assert kbh bị sai
        }
        balance  -= _amount;
        assert(balance <= oldBalance);
    }

    uint public count;
    function loop(uint n) public{
        for(uint i = 0; i < n; i++){
            count += 1;
        }
    }
    // Dùng vòng for phải đảm bảo k dùng hết gas. VD: dùng for với array.length => đảm bảo kích thước array fix vì nếu vì quá lớn sẽ hết gas và undone => nên check array length tại 1 giới hạn từ trước

    // require và revert sẽ k dùng hết gas như assert mà chạy đc đến đâu dùng đến đó thôi
}