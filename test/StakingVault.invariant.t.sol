// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {StakeToken} from "../src/StakeToken.sol";
import {StakingVault} from "../src/StakingVault.sol";

// A "handler" defines the random actions Foundry is allowed to take.
contract VaultHandler is Test {
    StakeToken public token;
    StakingVault public vault;

    constructor(StakeToken token_, StakingVault vault_) {
        token = token_;
        vault = vault_;
    }

    // Foundry will call these with random inputs, in random order, many times.

    function deposit(uint256 amount) public {
        amount = bound(amount, 0, token.balanceOf(address(this)));
        if (amount == 0) return;
        token.approve(address(vault), amount);
        vault.deposit(amount, address(this));
    }

    function withdraw(uint256 shares) public {
        shares = bound(shares, 0, vault.balanceOf(address(this)));
        if (shares == 0) return;
        vault.redeem(shares, address(this), address(this));
    }

    function addRewards(uint256 amount) public {
        amount = bound(amount, 0, token.balanceOf(address(this)));
        if (amount == 0) return;
        token.transfer(address(vault), amount);
    }
}

contract StakingVaultInvariantTest is Test {
    StakeToken token;
    StakingVault vault;
    VaultHandler handler;

    function setUp() public {
        token = new StakeToken();
        vault = new StakingVault(token);
        handler = new VaultHandler(token, vault);

        // Give the handler tokens to play with.
        token.transfer(address(handler), 500_000e18);

        // Tell Foundry: only call functions on the handler.
        targetContract(address(handler));
    }

    // THE INVARIANT: the vault must always hold at least as many assets
    // as the total shares claim to be worth. Never insolvent.
    function invariant_vaultIsSolvent() public view {
        uint256 totalShares = vault.totalSupply();
        uint256 assetsOwed = vault.convertToAssets(totalShares);
        uint256 actualAssets = token.balanceOf(address(vault));
        assertGe(actualAssets, assetsOwed);
    }
}