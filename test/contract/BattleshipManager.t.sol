// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {BattleshipManager} from "../../contracts/BattleshipManager.sol";
import {DeployBattleshipManager} from "../../script/DeployBattleshipManager.s.sol";
import {CreateGame} from "../../script/CreateGame.s.sol";
import {BoardConfiguration} from "../../script/BoardConfiguration.s.sol";
import {Game, Tile, Player, Turn} from "../../contracts/Structs.sol";

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

        assertPlayerIsValid(player1, createdGame.player1, boardConfiguration.getBoardProof1().input[0]);
        assertPlayerIsValid(player2, createdGame.player2, boardConfiguration.getBoardProof2().input[0]);

        assertTurnIsValid(player1, createdGame.turn);

        assertEq(address(0), createdGame.winner);
    }

    function assertTurnIsValid(address player, Turn memory turn) private {
        assertEq(player, turn.player);
        assertEq(0, turn.lastMove[0]);
        assertEq(0, turn.lastMove[1]);
        assertEq(true, turn.isFirstTurn);
    }

    function assertPlayerIsValid(address expectedFirstTurnPlayer, Player memory createdPlayer, uint256 boardCommitment) private {
        assertEq(expectedFirstTurnPlayer, createdPlayer.player);
        assertEq(boardCommitment, createdPlayer.boardCommitment);
        assertEq(17, createdPlayer.healthRemaining);
        assertBoardIsEmpty(createdPlayer.visibleBoard);
    }

    function assertBoardIsEmpty(Tile[10][10] memory board) private pure {
        for (uint8 i = 0; i < 10; i++) {
            for (uint8 j = 0; j < 10; j++) {
                assert(board[i][j] == Tile.UNKNOWN);
            }
        }
    }
}
