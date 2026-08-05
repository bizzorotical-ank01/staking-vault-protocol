// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {StakeToken} from "../src/StakeToken.sol";
import {StakingVault} from "../src/StakingVault.sol";
import {RewardDistributor} from "../src/RewardDistributor.sol";

contract DeployVault is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);

        // Deploy all three contracts, wired together.
        StakeToken token = new StakeToken();
        StakingVault vault = new StakingVault(token);
        RewardDistributor distributor = new RewardDistributor(token, address(vault));

        vm.stopBroadcast();

        console.log("StakeToken:       ", address(token));
        console.log("StakingVault:     ", address(vault));
        console.log("RewardDistributor:", address(distributor));
    }
}