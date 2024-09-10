pragma solidity ^0.8.0;

// # Data type
contract Test {
    // ufixed public fixVar = 1; // Kiểu này có nhưng k dùng được, sẽ abort CT
    int[3] public tes1t = [-11, 2, 3]; // k thể dùng push vì fix size, buộc có số âm bên trong
    // khai báo bth với string, mảng lớn hơn string thì tự động add 0 vào sau
    bytes public exampleBytes = '0xabcd';
    bytes32 public bytes32Var = "Hello World";
    // khai báo theo kiểu bytes, k dùng được với bytes mà chỉ dùng đc với bytes1,... tĩnh
    bytes1 public bytes1Var = 0x20;
    
    //láy giá trị
    function test(bytes1 data) public pure returns(bytes1){
        return data; 
    }
    function test1() public view returns(bytes memory){ // là mảng động nên cần specific data location
        return exampleBytes; 
    }
    function test2() public view returns(bytes32){
        return bytes32Var; 
    }
    
    // truyền vào hàm bytesN. Khi deploy phải truyền đúng kích thước
    function getVal(bytes1 data) public pure returns(bytes1){
        return data;
    }
    // truyền vào bytes thì deploy xong ta truyền vào kiểu bytesN nào cx đc vì mảng kích thước động mà. VD truyền được 0x20, còn 0x200 là sai
    function getVal2(bytes memory data) public pure returns(bytes memory){
        return data;
    } 
    
    // convert từ bytes sang bytes32 -> dùng assembly vì từ mảng động sang tĩnh thì k đơn giản vì chắc gì đủ kích thước lưu
    // convert từ bytesN sang bytes -> từ tĩnh sang động lại rất dễ vì động nó lưu vô hạn
    function bytesNToBytes(bytes1 _data) public pure returns (bytes memory) {
        return abi.encodePacked(_data); // lợi dụng các hàm của solidity toàn trả về bytes
    }
    
    // convert bytes to string
    function bytesToString(bytes memory data) public pure returns(string memory){
        return string(data);
    }
    // convert string to bytes
    function stringToBytes(string memory data) public pure returns(bytes memory){
        return bytes(data);
    }
    // do string với bytes nó gần như là 1 nên rất dễ lấy

    // sử dụng trong hàm bytes32
    function useBytes32() public view returns(bytes2){
        bytes32 bytes32VarIn = bytes32Var;
        bytes2 smallData = bytes32VarIn[0];// byte32 vẫn truy xuất được như mảng
        return smallData;
    }
    // sử dụng trong hàm bytes
    function useBytes() public view returns(bytes2){
        bytes memory exampleBytesIn = exampleBytes;
        bytes2 smallData = exampleBytesIn[0];
        return smallData;
    }
    
    // convert bytes32 to string: bytes32 -> bytes -> string. C1: assembly, C2: gán như dưới
    // sao k dùng luôn abi.encodePacked(..); cho nhanh
    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
    //convert string to bytes32: string -> bytes -> bytes32 => từ bytes sang bytes32 phải dùng assembly
    
    //convert bytes1 to uint thì: uint a = uint(uint8(<biến bytes1>)); vì cần dùng 8 bits uint để biểu diễn 1 byte
    //convert bytes to uint cx chỉ là convert từng bytes 1
    function bytesToUint(bytes memory b) public view returns (uint){
        uint number; // bytes[i] là kiểu bytes1

        for(uint i = 0; i < b.length; i++){
            number = number + uint(uint8(b[i]))*(2**(8*(b.length-(i+1))));
        }
        return number;
    }
}
