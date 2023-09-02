// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {BattleshipManager} from "../contracts/BattleshipManager.sol";
import {Verifier as VerifyBoardVerifier} from "../contracts/VerifyBoardVerifier.sol";
import {Verifier as VerifyImpactVerifier} from "../contracts/VerifyImpactVerifier.sol";
import {MockVerifyImpactVerifier} from "../test/contract/mock/MockVerifyImpactVerifier.sol";

contract DeployBattleshipManager is Script {
    function deploy(bool mockVerifyImpactVerifier) public returns (BattleshipManager) {
        vm.startBroadcast();
        VerifyBoardVerifier verifyBoardVerifier = new VerifyBoardVerifier();
        address verifyImpactVerifierAddress;
        if (mockVerifyImpactVerifier) {
            verifyImpactVerifierAddress = address(new MockVerifyImpactVerifier());
        } else {
            verifyImpactVerifierAddress= address(new VerifyImpactVerifier());
        }
        BattleshipManager battleshipeManager =
            new BattleshipManager(address(verifyBoardVerifier), verifyImpactVerifierAddress);
        vm.stopBroadcast();
        return battleshipeManager;
    }

    function run() external returns (BattleshipManager) {
        return deploy(false);
    }
}
