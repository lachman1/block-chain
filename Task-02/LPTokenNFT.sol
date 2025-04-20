// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPTokenNFT is ERC721URIStorage, Ownable {
    uint256 public tokenIdCounter;

    constructor() ERC721("LPToken", "LPNFT") Ownable(msg.sender) {}

    function mint(address to, string memory uri) external onlyOwner returns (uint256) {
        uint256 newId = tokenIdCounter;
        _mint(to, newId);
        _setTokenURI(newId, uri);
        tokenIdCounter += 1;
        return newId;
    }

    function updateURI(uint256 tokenId, string memory uri) external onlyOwner {
        _setTokenURI(tokenId, uri);
    }
}
