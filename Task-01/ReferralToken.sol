// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ReferralToken is ERC20, AccessControl {
    bytes32 public constant BACKEND_ROLE = keccak256("BACKEND_ROLE");

    mapping(address => address) public referrerOf;
    mapping(address => address[]) public referrals;

    event ReferralRegistered(address indexed referrer, address indexed referee);
    event RewardMinted(address indexed user, uint256 amount);

    constructor(address backendWallet) ERC20("ReferralToken", "RFT") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(BACKEND_ROLE, backendWallet);
    }

    function registerReferral(address referee, address referrer) external onlyRole(BACKEND_ROLE) {
        require(referee != address(0), "Invalid referee");
        require(referrer != address(0), "Invalid referrer");
        require(referrer != referee, "Self-referral not allowed");
        require(referrerOf[referee] == address(0), "Already referred");

        // Prevent circular referrals
        address current = referrer;
        while (current != address(0)) {
            require(current != referee, "Circular referral not allowed");
            current = referrerOf[current];
        }

        referrerOf[referee] = referrer;
        referrals[referrer].push(referee);

        emit ReferralRegistered(referrer, referee);

        uint256 rewardAmount = 100 * 10 ** decimals();
        _mint(referrer, rewardAmount);
        _mint(referee, rewardAmount);

        emit RewardMinted(referrer, rewardAmount);
        emit RewardMinted(referee, rewardAmount);
    }

    function getReferrals(address referrer) external view returns (address[] memory) {
        return referrals[referrer];
    }
}
