// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {StakeToken} from "../src/StakeToken.sol";
import {StakingVault} from "../src/StakingVault.sol";
import {RewardDistributor} from "../src/RewardDistributor.sol";

contract RewardDistributorTest is Test {
    StakeToken token;
    StakingVault vault;
    RewardDistributor distributor;

    address attacker = address(0xBAD);

    function setUp() public {
        token = new StakeToken();
        vault = new StakingVault(token);
        distributor = new RewardDistributor(token, address(vault));

        // Fund the distributor with reward tokens to hand out.
        token.transfer(address(distributor), 10_000e18);
    }

    function test_OwnerCanDistribute() public {
        uint256 vaultBefore = token.balanceOf(address(vault));

        // This test contract is the owner (it deployed the distributor).
        distributor.distribute(500e18);

        uint256 vaultAfter = token.balanceOf(address(vault));
        assertEq(vaultAfter - vaultBefore, 500e18);
    }

    function test_NonOwnerCannotDistribute() public {
        vm.prank(attacker);
        vm.expectRevert();
        distributor.distribute(500e18);
    }

    function test_CannotDistributeMoreThanBalance() public {
        vm.expectRevert("insufficient reward balance");
        distributor.distribute(20_000e18); // more than the 10,000 funded
    }
}