pragma solidity ^0.8;

error Overflow(uint val); // Tái sử dụng và rẻ, nên dùng thay hoàn toàn revert(<string>)

contract NewestVersion{
    function UseUnchecked() public pure returns(uint) {
        uint x = 0;
        uint y = x;
        unchecked{ x--; }
        //ở phiên bản mới, khi overflow hay underflow sẽ tự động báo lỗi và k quay vòng như trc. Nếu vẫn muốn quay vòng như trc thì thêm từ khóa uncheck{<code>}
        
        // Giả sử unchecked như trên gây ra kết quả k mong muốn, ta k nên dùng revert(<string>) mà nên dùng revert error vì string càng lớn thì gas càng tốn nhưng error thì rất rẻ
        if(x >= y){
            revert Overflow(x);
        }
        return x;
    }
    function testfunctionOutside(uint x) external pure returns(uint){
        return IncreaseByOne(x);
    }
    
    mapping(uint=>uint) a;
    function testFunctionOutside2() public {
        FunctionOutside(a);
    }

    // Test biến storage sẽ chỉ thao tác được với thuộc tính
    struct Transaction{
        uint age;
        string name;
    }
    Transaction public testStruct;
    function test(Transaction storage b) private {
        testStruct.age = 10; // Biến storage gán thuộc tính thì k sao
        b.age = 10;
        b = testStruct; // Gán kiểu storage pointer với 1 storage pointer khác đều k sao
    }
    
    string public jkl = "Hello";
    function test3(string storage str2) private {
        jkl = str2; // K sao vì cung là kiểu storage pointer
        // str2 = "Hel"; // Sai vì kiểu literal string và kiểu storage pointer khác nhau hoàn toàn
        // Do string k có thuộc tính gì nên kiểu string storage chả có ứng dụng gì, chỉ để lấy giá trị thì dùng memory đc r
    } 
}

// 1 function cx có thể dùng ở ngoài contract, nhưng function đó do k nằm trong contract nào nên k có storage, k có this nên bị giới hạn -> error và funtion dùng ngoài contract có thể đc import vào file khác để dùng
function IncreaseByOne(uint x) pure returns(uint) {
    return x + 1;
}
// Chớ hiểu nhầm là k có storage là k dùng đc storage, thực chất nó làm v là để ta tái sử dụng hàm trong nhiều contract trong file. Khi gọi ở trong contract khác thì mặc định là nó dùng storage của contract đó.

// VD dùng function outside để đổi state var của contract. Tuy nhiên bị hạn chế là ta k gọi hàm bên ngoài để thay đổi state var của contract là uint chẳng hạn vì nó k có tự khóa storage, chỉ các biến có từ khóa đó mới đổi được giá trị bằng outside function
function FunctionOutside(mapping(uint=>uint) storage a){
    a[1] = 5; // Đổi state var mapping thì đc chứ uint thì k vì k có storage
}

// Tham số truyền vào hàm là storage thì chỉ được dùng với hàm private
// Vấn đề về storage: Khi dùng cụ thể 1 biến storage, ta có thể lấy giá trị của nó nhưng nếu muốn đổi giá trị của biến storage sẽ bị sai. Lỗi là is not implicitly convert to expected type of storage pointer. 
// Tức nếu ta gán biến đó bằng 1 cái reference khác thì sai, nhưng nếu gán các thuộc tính của nó thì k sao hết như hàm trên. Khi thao tác vs 1 biến storage, nên nhớ nó là kiểu storage pointer và k thao tác được như bth
// => function bên ngoài chỉ đổi state var các biến vớ vẩn or k đổi state var thì ứng dụng lấy giá trị trả về, import vào file khác, tính toán tái sử dụng chứ k có ứng dụng nh
