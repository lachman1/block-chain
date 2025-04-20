// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./LPTokenNFT.sol";

contract StakingContract {
    IERC20 public stakingToken;
    LPTokenNFT public lpNFT;

    mapping(address => uint256) public stakedAmount;
    mapping(address => uint256) public lastUpdate;
    mapping(address => uint256) public lpTokenId;

    constructor(address _stakingToken, address _lpNFT) {
        stakingToken = IERC20(_stakingToken);
        lpNFT = LPTokenNFT(_lpNFT);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Stake more than zero");
        stakingToken.transferFrom(msg.sender, address(this), amount);

        if (lpTokenId[msg.sender] == 0) {
            string memory uri = generateMetadata(amount);
            uint256 newId = lpNFT.mint(msg.sender, uri);
            lpTokenId[msg.sender] = newId;
        }

        stakedAmount[msg.sender] += amount;
        lastUpdate[msg.sender] = block.timestamp;

        string memory updatedURI = generateMetadata(stakedAmount[msg.sender]);
        lpNFT.updateURI(lpTokenId[msg.sender], updatedURI);
    }

    function generateMetadata(uint256 totalStaked) internal pure returns (string memory) {
        return string(abi.encodePacked(
            "data:application/json;base64,",
            "eyJ0b3RhbF9zdGFrZWQiOiAi",
            toString(totalStaked),
            "In0="
        ));
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) { digits++; temp /= 10; }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
