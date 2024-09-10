// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

// # Minimal Proxy Contract

// C1:
// Cơ chế: muốn deploy contract CloneMe nh lần -> truyền địa chỉ của nó vào create_forwarder_to nó sẽ tạo ra contract MinimalProxy có masterCopy là nó -> xong gọi hàm trong nó bth
contract Factory{
    function create_forwarder_to(address cloneme) public returns(address){
        MinimalProxy minimalProxyContract = new MinimalProxy(cloneme);
        return address(minimalProxyContract);
    }
}
contract MinimalProxy{
    int public a = 10;
    address public masterCopy;
    constructor(address _masterCopy){
        masterCopy = _masterCopy;
    }
    // K cần đúng phần external public hay return gì hết cx đc. VD ở đây ta bỏ phần return đi cx được nhưng ta có thể thêm tính năng hay xử lý thêm gì ở trong hàm như này ok. Khi xử lý thêm thì k còn là minimal thôi
    function increaseA() external returns(uint){
        (bool success, bytes memory data) = masterCopy.delegatecall(msg.data);
        // msg.data ở đây chính là bytes4(keccak(increaseA()))
        require(success);
        uint x;
        assembly {
            x := mload(add(data, add(0x20, 0)))
        }
        return x;
    }
}
contract CloneMe{
    uint a = 10;
    function increaseA() public returns(uint){
        a++;
        return a;
    }
    // 2 hàm dưới return the same
    function testmsgdata1() public pure returns(bytes4){
        return bytes4(keccak256("test3()"));
    }
    function testmsgdata2() public pure returns(bytes memory){
        return msg.data;
    }
}

//C2: thao tác với bytecode
/*Cơ chế: toàn bộ code của contract Factory và MinimalProxy nó tóm gọn trong đoạn bytecode tổng 55 bytes là:
3d602d80600a3d3981f3 / 363d3d373d3d3d363d73 bebebebebebebebebebebebebebebebebebebebe 5af43d82803e903d91602b57fd5bf3
=> Xem được 2 loại code này. Có thể in ra trong solidity
Đây là đoạn code mà EVM sẽ hiểu sau khi ta compile contract, nhưng ta có thể thao tác trực tiếp với bytecode bằng assembly trong solidity. Với contract bth thì bytecode của nó chia làm 2 phần: creation code và runtime code
Creation code là constructor or initial setup trả ra runtime code và khi gọi hàm thì EVM sẽ execute runtime code. Bên trái là creationcode, phải là runtime code
Ta xét 1 contract minimal proxy thì nó k có constructor nên creation code của nó chỉ bao gồm những thứ setup khác. Khi gọi hàm thì runtime code của nó là đoạn bebebebebebebebebebebebebebebebebebebebe ở giữa, nó sẽ là địa chỉ fix để delegate call gọi tới. Các giá trị khác thì là fix nếu như ta chủ ý tạo minimal proxy contract hết như trên
*/
contract MinimalProxyC2 {
    function clone(address target) external returns (address result) {
        // Convert address to 20 bytes
        bytes20 targetBytes = bytes20(target);
        // Thao tác vói bytecode nên chuyển address sang bytes20 thế vào đoạn bebe.. ở giữa

        // actual code
        // 3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3

        // creation code
        // copy runtime code into memory and return it
        // 3d602d80600a3d3981f3

        // runtime code 
        // code to delegatecall to address
        // 363d3d373d3d3d363d73 <address> 5af43d82803e903d91602b57fd5bf3

        assembly {
            /*
            Reads the 32 bytes of memory starting at pointer stored in 0x40=64

            In solidity, the 0x40 slot in memory is special: it contains the "free memory pointer" which points to the end of the currently allocated memory.
            Muốn thao tác gì đều phải bắt đầu từ 0x40 trở đi. Kể từ vị trí này xuất hiện 1 biến là free memory pointer, cứ gán lên bao nhiêu bytes là con pointer này tự động trỏ đến vị trí sau bytes đó
            */
            let clone := mload(0x40)
            // Clone lưu 32 bytes đầu từ vị trí 0x40(vị trí bắt đầu thao tác) nhưng thật ra ta chả quan tâm số byte mà đúng ra clone lưu vị trí thì tức là ta đang dịch nó đến vị trí thao tác mà thôi
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )

            /*
            Clone gán xong thì free memory pointer tự động nhảy đến sau vị trí gán
              |              20 bytes                |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
                                                      ^
                                                    pointer => free memory pointer lưu ở 20 bytes đầu mà ta bỏ qua
            */
            // Store 32 bytes to memory starting at "clone" + 20 bytes
            // 0x14 = 20
            mstore(add(clone, 0x14), targetBytes)

            /*
            Lưu tiếp 20 bytes sau kể từ clone + 20 bằng địa chỉ, pointer tự nhảy tiếp  đến cuối
            lưu ý là do ta cần lưu từ địa chỉ 0x40 trở đi nên về sau mstore phải dùng hàm add 
            để lưu tiếp từ vị trí nào cứ tiến dần lên
              |               20 bytes               |                 20 bytes              |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe
                                                                                              ^
                                                                                              pointer
            */
            // Store 32 bytes to memory starting at "clone" + 40 bytes
            // 0x28 = 40
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            // Cuối cùng lưu phần còn lại -> dôi ra 0000 chả sao

            /*
              |               20 bytes               |                 20 bytes              |           15 bytes          |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3
            */
            // Create new contract
            // Send 0 Ether
            // Code starts at pointer stored in "clone"
            // Code size 0x37 (55 bytes)
            result := create(0, clone, 0x37)
            // Càm create đơn giản hơn create2, ở đây ta deploy contract với giá trị trên

            // Vl cái này chỉ là khởi tạo contract CloneMe bằng hàm create thôi mà. 
        }
    }
}
