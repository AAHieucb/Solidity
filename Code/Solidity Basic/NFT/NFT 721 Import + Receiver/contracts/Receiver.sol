// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract Receiver{
    function onERC721Received( // Phải có hàm này ms nhận được bằng safeTransferFrom
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data // calldata giống memory + tính năng cắt được
    ) external returns (bytes4) {
        msg.sender.call(data);
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }
    function getData(address addr, uint tokenId) public view returns(bytes memory) {
        return abi.encodeWithSignature("transferFrom(address,address,uint256)",
        address(this), addr, tokenId);
    }
}
// Vai trò của data trong các hàm thực ra là để dùng nt này, ta có thể gọi tiếp thêm 1 hàm nx ngay tại onERC721Received bằng cách truyền vào thông qua đối số data để gọi
// Ở đây ta truyền vào kèm data là hàm transfer gửi tiếp cho address kia token thứ 10
// nếu truyền data là như v. Đỡ mất phí 2 lần
// Nếu k gọi ở đây cx chả sao nếu bên trong hàm receive có hàm nào khác gọi transfer cx đc nhưng nếu k có hàm nào khác gọi transfer như v thì NFT sẽ bị lock trong contract mãi mãi

// Cơ chế: người dùng tạo và sở hữu cho mình 1 token ERC721 -> người dùng đó gọi hàm safeTransferFrom của contract ERC721(gửi từ người đó, tới contract Receiver, đối số 4 là bytes là signature hàm transferFrom từ Receiver tới người nhận) -> Receiver nhận được gọi vào onERC721Received -> bên trong lại gọi msg.sender cái biến bytes -> msg.sender lại là contract ERC721 ban đầu gọi transferFrom từ Receiver tới người nhận thế là token được gửi gọi 2 hàm 1 lần
// Thật ra nó chỉ có lợi trong code thôi, nếu ta code lại logic hàm tranferFrom vào onERC721Received cũng tương tự nhưng nếu muốn gọi nhiều hàm khác nhau thì mỗi hàm sẽ phải tạo code lại onERC721Received