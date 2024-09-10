pragma solidity >=0.7.0 <0.9.0;

// # Basic

contract First{
    string public text = "Hello";
    // Khi khai báo string phải khai báo data location. Có 2 loại: nếu dùng storage thì dữ liệu phải được lưu trong smart contract nằm trong block, nhưng string này được lấy từ bên ngoài người dùng nhập. Vào và chỉ available khi function exec nên dùng memory. Hay nói cách khác mọi function input là public đều phải dùng memory
    function set(string memory _text) public { 
        text = _text; // text là state var, _text thì k
    }

    // Tự tạo getter dù sol tự tạo getter r vì là biến public
    // memory là lưu từ ngoài vào nhưng ở đây ta dùng vì solidity sẽ copy data trong storage vào memory và return nên đúng hơn là ta lấy từ memory chứ k tác động trực tiếp vào data trong blockchain. Các cái tương tác từ bên ngoài đều là memory. VD hàm internal truyền vào đổi biến storage mới dùng params là storage thôi
    // Tức data location của returns kbh là storage
    function get() public view returns (string memory){
        return text;
    }
    
    // Thêm đơn vị vào sau số chỉ có tác dụng định lượng
    // wei là đơn vị nhỏ nhất và sẽ hiển thị theo kiểu bao nhiêu wei, các thứ khác sẽ quy đổi sang wei
    uint public oneWei = 1 wei;
    uint public oneEther = 1 ether; // K đc dùng biến với đơn vị như x ether là sai
    function testOneWei() public pure returns (bool){
        return 1 wei == 1;
    }
    function testOneEther() public pure returns (bool) {
        return 1 ether == 1e18 wei;
    }
    function testGasRefund() public view returns (uint){
        return tx.gasprice; // gasprice*(số lượng gas sử dụng) = totalgas
    }
    
    // K chạy hàm này nếu k sẽ toang Ct. GT của i sẽ về lại 0 nhưng vẫn ngốn gas vì invalid. Nó dùng hết max gas thì thôi
    uint public i = 0;
    function invalidTransRunForever() public {
        while(true){
            i++;
        }
    }
    
    // Các quy tắc giới hạn cho pub function: array và mapping
    // function mappingInput(mapping(uint=>uint) memory mapVar) public{ } // mapping k được truyền vào hàm public

    // Chú ý là private luôn là storage, còn public là storage hay memory tùy TH (đã biết)
    function muldimensionalArrDynamicSize(uint[9][9] memory _arr) public { }
    function mappingInput(mapping(uint=>uint) storage mapVar) private{ }
    // function muldimensionalArrDynamicSize(uint[][] memory _arr) public { }
    // Ng ta bảo k nên dùng arr k rõ số lượng ptu ở input. NN là vì càng nhiều input thì càng nhiều gas, ta tạo 1 function dynamic size với mong muốn có vài phần tử, nhưng người dùng cứ truyền vào nhiều phần tử khiến lượng gas cực lớn và function k chạy được. Tức là input đúng với 1 arr này nhưng lại fail với arr khác. Điều này là k chuẩn với tc của 1 smart contract là simple, reliable, predictable. Nếu dùng, ta nên dùng array fixed size or check như này
    uint MAX_ARR_LENGTH = 10;
    function arrayInput(uint[] memory _arr) public {
        if(_arr.length > MAX_ARR_LENGTH){
            //throw error
        }
    }
    // Khi dùng public, k thể truyền mapping vào hàm số nên ta chỉ có thể dùng private, khi đó có thể cho 1 hàm khác gọi đến nó truyền vào 1 state var là 1 mapping. Mapping cách duy nhất là storage trong hàm private mà thôi, có thể truyền mảng 2 chiều vào public function như này ["",""]["",""] trong remix
    
    function returnMultiVals() public pure returns(uint, bool, uint){
        return (1, true, 2);
    }
    // Or đặt tên multival cx đc
    function named() public pure returns(uint x, bool b, uint y){
        return (1, true, 2);
    }
    function assigned() public pure returns(uint x, bool b, uint y){
        x = 1;
        b = true;
        y = 2; // Có thể tính toán với x, b, y r kết quả có được cuối cùng là giá trị cần tìm
        // Tức là bản chất hàm return cũng chỉ là khởi tạo biến copy x, b, y r gán cho như này mà thôi
    }
    // 1 hàm số có thể return multifunction bên trong nhưng các multifunction k đc return multivar mà chỉ return
    // 1 var. Nếu ta muốn lấy giá trị của 1 function multi vars thì ez thôi:
    function combination() public view returns(uint, bool, uint, uint, uint){
        (uint a, bool b, uint c) = named();
        (uint x, uint y) = (3,4);
        return (a, b, c, x, y);
    }

    // Trong solidity để concat string thì phải làm như này sẽ save gas
    function concat() public returns(string memory){
        text = string(abi.encodePacked(text, " WOrld")); // Phải gọi string sẽ tạo ra biến string copy convert sang
        return text;
    }

    // Output return của function cx phải cẩn trọng như input. K đc return 1 dynamic size arr. VD contract A có hàm như v. Sau này, 1 contract B nào đó gọi hàm đó của contract A để lấy arr dynamic size đó -> lúc đó nhỡ may size arr quá lớn thì hàm đó của contract B sẽ broke ngay. Cho nên cả input và output k nên dùng dynamic size arr
}
