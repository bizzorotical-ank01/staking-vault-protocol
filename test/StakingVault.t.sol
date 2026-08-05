// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {StakeToken} from "../src/StakeToken.sol";
import {StakingVault} from "../src/StakingVault.sol";

contract StakingVaultTest is Test {
    StakeToken token;
    StakingVault vault;

    address alice = address(0xA11CE);

    function setUp() public {
        // Deploy the token (this test contract gets the 1M initial supply).
        token = new StakeToken();
        // Deploy the vault, pointing it at our token.
        vault = new StakingVault(token);

        // Give Alice 1000 tokens to stake.
        token.transfer(alice, 1000e18);
    }

    function test_DepositMintsShares() public {
        vm.startPrank(alice);
        token.approve(address(vault), 1000e18);
        uint256 shares = vault.deposit(1000e18, alice);
        vm.stopPrank();

        // First depositor gets shares 1:1 with assets.
        assertEq(shares, 1000e18);
        assertEq(vault.balanceOf(alice), 1000e18);
    }

    function test_RewardsIncreaseShareValue() public {
        // Alice deposits 1000 tokens.
        vm.startPrank(alice);
        token.approve(address(vault), 1000e18);
        vault.deposit(1000e18, alice);
        vm.stopPrank();

        // Rewards arrive: 500 tokens sent straight into the vault.
        token.transfer(address(vault), 500e18);

        // Alice still holds the same shares, but they're now worth more.
        // 1000 shares now redeem for the full 1500 tokens in the vault.
        uint256 redeemable = vault.convertToAssets(vault.balanceOf(alice));
        assertApproxEqAbs(redeemable, 1500e18, 1e6);
    }

    function test_WithdrawReturnsAssetsPlusYield() public {
        // Alice deposits 1000 tokens.
        vm.startPrank(alice);
        token.approve(address(vault), 1000e18);
        vault.deposit(1000e18, alice);
        vm.stopPrank();

        // Rewards arrive.
        token.transfer(address(vault), 500e18);

        // Alice redeems all her shares.
        vm.startPrank(alice);
        vault.redeem(vault.balanceOf(alice), alice, alice);
        vm.stopPrank();

        // Started with 1000, staked it, now holds ~1500. That's the yield.
        assertApproxEqAbs(token.balanceOf(alice), 1500e18, 1e6);
    }
}
