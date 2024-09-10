// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MyIERC165.sol";

// # NFT
// interface kế thừa 1 interface khác, k cần khai báo hàm của interface kia nhưng contract kế thừa interface này cx như kế thừa 2 interface 1 lúc và phải khai báo lại hàm. Tức là contract ERC721 chính lúc này vừa kết thừa IERC165, lại vừa kế thừa IERC721, tức là nó dùng được hàm của ERC165 và vẫn phải tự mình khai báo hàm supportsInterface cho chính nó vì kế thừa IERC165.
// => Ta thg làm 1 interface nào đó kế thừa IERC165 là vì ta muốn contract của ta khi dùng interface đó sẽ phải cung hàm supportsInterface cho interface đó
// Tức ở đây ERC721 sẽ phải cung supportsInterface cho IERC721
interface IERC721 is MyIERC165 {
    // Event thì k cần reimplement
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    
    // Trong ERC721 k có transfer mà chỉ có transferFrom thì nó làm gộp 2 hàm lại là k cần approve như ERC20 bằng _isApprovedOrOwner
    // ERC20 k gộp chung lại vì ví nó thực hiện 2 hàm khác nhau
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
