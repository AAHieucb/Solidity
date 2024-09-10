pragma solidity >=0.7.0 <0.9.0;

contract Game {
    // # Basic / Block hay memory
    bool myBoolean = true;
    uint myUnsignedInteger = 10;
    int myInteger = -10;
    string myString = "My String";
    address myAdress = msg.sender;
    
    enum Level{ Beginner, Intermediate, Advanced}
    // UD: tiêu bao nhiêu token thì lên level kiểu đa cấp chẳng hạn -> có nh ưu đãi hơn, chức năng tốt hơn
    
    Player[] public players;
    struct Player {
        address addressPlayer;
        string fullName;
        Level myLevel;
        uint age;
        string gender;
        uint createdTime;
    }
    function addPlayer(string memory fullName, uint age, string memory gender) public 
    {
        // memory là lưu trữ trong memory thêm khi truyền vào string
        players.push(Player(msg.sender, fullName, Level.Intermediate, age, gender, block.timestamp));
        playersMap[msg.sender] = Player(msg.sender, fullName, Level.Intermediate, age, gender, block.timestamp);
        // block truy cập thông tin block hiện tại chứa transaction này
        countPlayer++; // k cần thiết => lấy length của mảng Player là được
    }
    
    uint public countPlayer = 0;
    
    mapping(address => Player) public playersMap;
    // kiểu map cho duy nhất 1 key thành 1 value
    // VD: chạy chương trình tại 1 địa chỉ -> thêm 1 player vào địa chỉ đó -> sửa player -> thêm tiếp player 
    // nx vào địa chỉ đó. KQ mảng có 2 player, map thì chỉ có 1 nên value of key địa chỉ đó là cái sau khi
    // ta sửa. UD: 1 address chỉ đk đc 1 player
    
    function getPlayerLevel(address addressPlayer) public view returns(Level){
        return playersMap[addressPlayer].myLevel;
    }
    
    // VD: player càng lâu thì lên Level
    function changePlayerLevel(address playerAddress) public{
        Player storage player = playersMap[playerAddress];
        // Nếu muôn lưu thành biến mà có sự thay đổi từ struct, array, mapping thì phải cho datalocation như này
        // đa phần chỉ có khởi tạo là không cần còn mọi lúc khác đều phải dùng data location như này
        // dùng là storage => truy cập địa chỉ biến đó; dùng là memory => copy nên đổi sẽ k đổi biến gốc trong storage
        if(block.timestamp >= player.createdTime + 15){
            player.myLevel = Level.Advanced;
        }
    }
    // kích hoạt hàm này sau 15s add player sẽ thấy level đổi
    // block.timestamp là thời điểm hiện tại kể từ epoch time đơn vị giây
}