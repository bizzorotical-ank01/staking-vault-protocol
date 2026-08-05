// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract RewardDistributor is Ownable {
    using SafeERC20 for IERC20;
    IERC20 public immutable rewardToken;
    address public immutable vault;

    event RewardsDistributed(uint256 amount);

    constructor(IERC20 rewardToken_, address vault_)
        Ownable(msg.sender)
    {
        rewardToken = rewardToken_;
        vault = vault_;
    }

    // Owner sends `amount` of reward tokens from this contract into the vault.
    function distribute(uint256 amount) external onlyOwner {
        require(amount > 0, "amount must be positive");
        require(
            rewardToken.balanceOf(address(this)) >= amount,
            "insufficient reward balance"
        );

        rewardToken.safeTransfer(vault, amount);
        emit RewardsDistributed(amount);
    }
}