// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";

import {HackathonManagement} from "../src/HackathonManagement.sol";

contract ContractScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        HackathonManagement _contract = new HackathonManagement();

        vm.stopBroadcast();
    }
}
