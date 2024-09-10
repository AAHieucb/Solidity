// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Vc ta chia ra nhiều interface để khi contract khác dùng contract ERC721 của ta thì họ khai báo interface để gọi hàm dễ dàng check xem contract của ta có dùng interface đó k
interface IERC721Enumerable{
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}
