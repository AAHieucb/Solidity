// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// # Access private variable

/*
Deploy lên testnet để dùng web3 tương tác với contract
VD contract này trên ropstent tại
0x3505a02BCDFbb225988161a95528bfDb279faD6b => bỏ
*/

contract Vault {
    // slot 0
    uint public count = 123;
    // slot 1
    address public owner = msg.sender;
    bool public isTrue = true;
    uint16 public u16 = 31;
    // slot 2
    bytes32 private password;

    // Hằng số trong solidity có từ khóa constant k được lưu trong storage nó sẽ được hard-coded trong contract bytecode
    uint public constant someConst = 123;

    // slot 3, 4, 5 (one for each array element) -> fix size
    bytes32[3] public data;

    struct User {
        uint id;
        bytes32 password;
    }

    // Dynamic array thì next slot sẽ lưu length of nó mà thôi
    // slot 6 - length of array
    // Còn array data store thực tế bắt đầu từ slot hash(6) - array elements
    // slot where array element is stored = keccak256(slot)) + (index * elementSize)
    // Ở TH này mỗi var chiếm 2 slot cho id và password. 
    // Trong VD này thì phần tử thứ 2 của arr lưu tại keccak256(6) + 2 (1 (uint) +  1 (bytes32))
    User[] private users;

    // slot 7 - empty
    // Values of mapping are stored at hash(key, slot). VD TH này thì slot = 7, key = map key là số uint
    mapping(uint => User) private idToUser;

    constructor(bytes32 _password) {
        password = _password;
    }

    function addUser(bytes32 _password) public {
        User memory user = User({id: users.length, password: _password});

        users.push(user);
        idToUser[user.id] = user;
    }

    // Helper để tính slot lấy private var cho dễ
    function getArrayLocation(
        uint slot,
        uint index,
        uint elementSize
    ) public pure returns (uint) {
        return uint(keccak256(abi.encodePacked(slot))) + (index * elementSize);
    }

    function getMapLocation(uint slot, uint key) public pure returns (uint) {
        return uint(keccak256(abi.encodePacked(key, slot)));
    }
}
// Thử lấy password và user là private xem sao
/*
Để test dự án đã được deploy lên ropstent sẵn r, ta vào 1 dự án truffle có config với ropsten -> truffle console --network ropsten
Hàm getStorageAt nhận data lưu tại địa chỉ contract nào, slot thứ bao nhiêu

slot 0 - count
web3.eth.getStorageAt("0x3505a02BCDFbb225988161a95528bfDb279faD6b", 0, console.log) => parseInt(<>, 10) để nhìn vì nó lưu dạng hex
slot 1 - u16, isTrue, owner
web3.eth.getStorageAt("0x3505a02BCDFbb225988161a95528bfDb279faD6b", 1, console.log)
slot 2 - password
web3.eth.getStorageAt("0x3505a02BCDFbb225988161a95528bfDb279faD6b", 2, console.log)
=> nhận được dạng hex, ta đổi sang ký tự với web3.utils.toAscii("<>")

slot 6 - array length
getArrayLocation(6, 0, 2)
web3.utils.numberToHex("111414077815863400510004064629973595961579173665589224203503662149373724986687")
Note: We can also use web3 to get data location
web3.utils.soliditySha3({ type: "uint", value: 6 })
1st user
web3.eth.getStorageAt("0x3505a02BCDFbb225988161a95528bfDb279faD6b", "0xf652222313e28459528d920b65115c16c04f3efc82aaedc97be59f3f377c0d3f", console.log)
web3.eth.getStorageAt("0x3505a02BCDFbb225988161a95528bfDb279faD6b", "0xf652222313e28459528d920b65115c16c04f3efc82aaedc97be59f3f377c0d40", console.log)
Note: use web3.toAscii to convert bytes32 to alphabet nhìn password từng user
2nd user
web3.eth.getStorageAt("0x3505a02BCDFbb225988161a95528bfDb279faD6b", "0xf652222313e28459528d920b65115c16c04f3efc82aaedc97be59f3f377c0d41", console.log)
web3.eth.getStorageAt("0x3505a02BCDFbb225988161a95528bfDb279faD6b", "0xf652222313e28459528d920b65115c16c04f3efc82aaedc97be59f3f377c0d42", console.log) // +1 để sang vị trí next slot
=> Ở đây khá ảo là array nó lưu phần tử tại vị trí hash(6) mà k sợ các giá trị hash(x) khác sẽ trùng or gần đó vì nó tin tưởng khoảng quá lớn để bị trùng, dẫn đến position lưu là tại vị trí 1 đoạn hash dài.

slot 7 - empty
web3.eth.getStorageAt(<address>,<slot>,console.log)
getMapLocation(7, 1)
web3.utils.numberToHex("81222191986226809103279119994707868322855741819905904417953092666699096963112")
Note: We can also use web3 to get data location
web3.utils.soliditySha3({ type: "uint", value: 1 }, {type: "uint", value: 7}) => tương tự keccak
user 1
web3.eth.getStorageAt("0x3505a02BCDFbb225988161a95528bfDb279faD6b", "0xb39221ace053465ec3453ce2b36430bd138b997ecea25c1043da0c366812b828", console.log)
web3.eth.getStorageAt("0x3505a02BCDFbb225988161a95528bfDb279faD6b", "0xb39221ace053465ec3453ce2b36430bd138b997ecea25c1043da0c366812b829", console.log)
*/