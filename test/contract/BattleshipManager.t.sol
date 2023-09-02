// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {BattleshipManager} from "../../contracts/BattleshipManager.sol";
import {DeployBattleshipManager} from "../../script/DeployBattleshipManager.s.sol";
import {CreateGame} from "../../script/CreateGame.s.sol";
import {BoardConfiguration} from "../../script/BoardConfiguration.s.sol";
import {Game, Tile, Player} from "../../contracts/Structs.sol";

contract BattleshipManagerTest is Test {
    BattleshipManager public battleshipManager;

    function setUp() public {
        DeployBattleshipManager deployBattleshipManager = new DeployBattleshipManager();
        battleshipManager = deployBattleshipManager.run();
    }

    function testCreateGame() public {
        CreateGame createGame = new CreateGame();
        BoardConfiguration boardConfiguration = new BoardConfiguration();

        address player1 = address(1);
        address player2 = address(2);

        createGame.createGame(battleshipManager, boardConfiguration, player1, player2);
        Game memory createdGame = battleshipManager.getGame(0);

        assertEq(player1, createdGame.player1.player);
        assertEq(boardConfiguration.getBoardProof1().input[0], createdGame.player1.boardCommitment);
        assertBoardIsEmpty(createdGame.player1.visibleBoard);

        assertEq(player2, createdGame.player2.player);
        assertEq(boardConfiguration.getBoardProof2().input[0], createdGame.player2.boardCommitment);
        assertBoardIsEmpty(createdGame.player2.visibleBoard);

        assertEq(player1, createdGame.turn);
        assertEq(address(0), createdGame.winner);
    }

    function assertBoardIsEmpty(Tile[10][10] memory board) internal pure {
        for (uint8 i = 0; i < 10; i++) {
            for (uint8 j = 0; j < 10; j++) {
                assert(board[i][j] == Tile.UNKNOWN);
            }
        }
    }
}
