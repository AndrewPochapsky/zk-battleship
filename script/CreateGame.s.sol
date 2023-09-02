// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {BattleshipManager} from "../contracts/BattleshipManager.sol";
import {BoardConfiguration} from "./BoardConfiguration.s.sol";
import {BoardProof} from "../contracts/Structs.sol";

contract CreateGame is Script {
    function createGame(
        BattleshipManager battleshipManager,
        BoardConfiguration boardConfiguration,
        address player1,
        address player2
    ) public {
        BoardProof memory boardProof1 = boardConfiguration.getBoardProof1();
        BoardProof memory boardProof2 = boardConfiguration.getBoardProof2();
        vm.startBroadcast();
        battleshipManager.createGame(player1, boardProof1, player2, boardProof2);
        vm.stopBroadcast();
    }

    function run() external {
        address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
        address player1 = vm.envAddress("PLAYER1_PUB");
        address player2 = vm.envAddress("PLAYER2_PUB");
        BattleshipManager battleshipManager = BattleshipManager(contractAddress);
        BoardConfiguration boardConfiguration = new BoardConfiguration();

        createGame(battleshipManager, boardConfiguration, player1, player2);
    }
}
