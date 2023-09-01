// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {BattleshipManager} from "../contracts/BattleshipManager.sol";
import {Verifier as VerifyBoardVerifier} from "../contracts/VerifyBoardVerifier.sol";
import {Verifier as VerifyImpactVerifier} from "../contracts/VerifyImpactVerifier.sol";

contract DeployBattleshipManager is Script {
    function run() external returns (BattleshipManager) {
        vm.startBroadcast();
        VerifyBoardVerifier verifyBoardVerifier = new VerifyBoardVerifier();
        VerifyImpactVerifier verifyImpactVerifier = new VerifyImpactVerifier();
        BattleshipManager battleshipeManager =
            new BattleshipManager(address(verifyBoardVerifier), address(verifyImpactVerifier));
        vm.stopBroadcast();
        return battleshipeManager;
    }
}
