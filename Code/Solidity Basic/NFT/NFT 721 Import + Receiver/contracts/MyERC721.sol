// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// # NFT
// Deploy ERC721 -> mint cho msg.sender 1 lượng -> msg.sender gửi nó đi bằng transferFrom thì cho contract nào 
// cx đc -> gửi NFT đi bằng safeTransferFrom cho contract Receiver thì contract đó phải có hàm onERC721Received
// trả ra selector của hàm onERC721Received
contract MyNFTERC721 is ERC721{
        using Strings for uint256;
        string public baseURI = "https://raw.githubusercontent.com/hieucuopbien123/Public-data/main/cards/";
        
        constructor() ERC721("First NFT", "FNFT") { }
        
        function tokenURI(uint256 tokenId) public view override returns(string memory){
            require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
            string memory bUri = baseURI;
            return bytes(bUri).length > 0
                ? string(abi.encodePacked(bUri, tokenId.toString(), ".json"))
                : "";
        }
        
        function mint(address to, uint256 tokenId) external {
            _mint(to, tokenId);
        }
}