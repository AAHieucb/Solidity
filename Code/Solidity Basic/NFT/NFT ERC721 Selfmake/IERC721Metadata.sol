// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../IERC721.sol";

// ERC721 kế thừa cả IERC721 và IERC721Metadata nên cho kế thừa ở đây là thừa thãi dù k sai
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}