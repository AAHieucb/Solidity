pragma solidity >=0.8.0;

// # Math trong solidity
contract FullMath{
    uint a = 9;
    uint b = 10;
    function test() public pure returns(uint){
        uint day = 3 days;
        return day ; // luôn trả ra đơn vị tiêu chuẩn nhỏ nhất là s
    }
    function test1() public pure returns(uint){
        return 2.99792458e8; // scientific notation, nhưng kiểu gì cx phải nguyên.
        // VD: 2.997924e8 sẽ là 2.99792400
    }
    
    // Trong solidity, compile time sẽ tính toán cả floating point, nhưng run time thì k
    // TH1: chia 2 biến tạo ra floating point thì nó kp là constant expression nên compile k tính toán trước
    // lúc runtime nó k tính floating point mà tính như uint bth nên làm tròn là 0 -> return uint thỏa mãn
    function test2() public view returns(uint){
        return a/b;
    }
    // TH2: hàm return bên dưới là constant expression -> nên compiler sẽ xử lý luôn và tính toán như floating point nhưng tính xong kết quả ra là 1 tức uint -> lại return uint thỏa mãn => chứ k sợ phép chia được thực hiện trước bị sai vì constant expression được compiler xử lý mượt như floating point bth rồi ra đúng uint nên k lỗi
    function test3() public pure returns(uint){
        return 7523 / 48124631 * 6397;
    }
    // TH3: lúc compile nó tính luôn giá trị vì là constant expression. Compile time tính cả giá trị floating point
    // và kết quả ra số thập phân, nhưng return lại uint -> lỗi luôn từ lúc compile time vì sai kiểu
    // function test4() public pure returns(uint){
        // return 7523 / 7524 * 6397; // lỗi
    // }

    // VD dùng là: uint number = 3/100*10 -> sai luôn vì tính ra rational mà lưu ở uint là sai ngay từ compile time
    // Để fix TH này là ta muốn tính theo uint chứ kp tính theo float: Nên nhớ compiler solidity k tự cast từ kiểu rational sang uint được. Do đó để fix được nó, hoặc là giá trị trả ra nguyên, hoặc là ta phải bảo compiler từ đầu luôn là tính theo nguyên chứ k tính theo float nx vì mặc định compiler tính theo giá trị float => uint number = uint(3)/100*10 => chú ý ta cast 3 sang uint thì nó tính phép chia như uint chứ k được: uint(3/100) là tính phép chia trc r mới cast thì sai vì đã bảo là compiler k cast được từ rational sang uint được. Khi đã fix đúng thì number luôn = 0 vì tính như uint mà
    // => Tức là mọi thứ vẫn ổn chỉ có duy nhất 1 vấn đề là compile time tính constant expression theo float và từ float k cast sang giá trị nào được
}
