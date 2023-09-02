// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {BattleshipManager} from "../../contracts/BattleshipManager.sol";
import {DeployBattleshipManager} from "../../script/DeployBattleshipManager.s.sol";
import {CreateGame} from "../../script/CreateGame.s.sol";
import {BoardConfiguration} from "../../script/BoardConfiguration.s.sol";
import {Game, Tile, Player, Turn, ImpactProof} from "../../contracts/Structs.sol";

contract BattleshipManagerTest is Test {
    BattleshipManager public battleshipManager;
    CreateGame public createGame;
    BoardConfiguration public boardConfiguration;

    address constant PLAYER1 = address(1);
    address constant PLAYER2 = address(2);

    function setUp() public {
        DeployBattleshipManager deployBattleshipManager = new DeployBattleshipManager();
        battleshipManager = deployBattleshipManager.run();
        createGame = new CreateGame();
        boardConfiguration = new BoardConfiguration();
    }

    function testCreateGame() public {
        createGame.createGame(battleshipManager, boardConfiguration, PLAYER1, PLAYER2);
        Game memory createdGame = battleshipManager.getGame(0);

        assertPlayerIsValid(PLAYER1, createdGame.player1, boardConfiguration.getBoardProof1().input[0]);
        assertPlayerIsValid(PLAYER2, createdGame.player2, boardConfiguration.getBoardProof2().input[0]);

        assertTurnIsValid(PLAYER1, createdGame.turn);

        assertEq(address(0), createdGame.winner);
    }

    modifier gameCreated() {
        vm.prank(PLAYER1);
        createGame.createGame(battleshipManager, boardConfiguration, PLAYER1, PLAYER2);
        _;
    }

    function testPlayFirstTurnInvalidPlayer() public gameCreated {
        vm.expectRevert("Not your turn");
        vm.prank(PLAYER2);
        battleshipManager.playFirstTurn(0, [0, 0]);
    }

    /// forge-config: default.fuzz.runs = 5
    function testPlayFirstTurnInvalidCoordinates(uint8 x, uint8 y) public gameCreated {
        vm.assume(x >= 10 || y >= 10);

        vm.expectRevert("Coordinate is not valid");
        vm.prank(PLAYER1);
        battleshipManager.playFirstTurn(0, [x, y]);
    }

    /// forge-config: default.fuzz.runs = 5
    function testPlayFirstTurnHappy(uint8 x, uint8 y) public gameCreated {
        vm.assume(x < 10 && y < 10);

        vm.prank(PLAYER1);
        battleshipManager.playFirstTurn(0, [x, y]);

        Game memory game = battleshipManager.getGame(0);
        Turn memory turn = game.turn;

        assertEq(PLAYER2, turn.player);
        assertEq(x, turn.lastMove[0]);
        assertEq(y, turn.lastMove[1]);
        assertEq(false, turn.isFirstTurn);
    }

    modifier firstTurnPlayed(uint8 x, uint8 y) {
        vm.prank(PLAYER1);
        battleshipManager.playFirstTurn(0, [x, y]);
        _;
    }

    function testPlayFirstTurnNotFirstTurn() public gameCreated firstTurnPlayed(0, 0) {
        vm.expectRevert("It is not the first turn");
        battleshipManager.playFirstTurn(0, [0, 0]);
    }

    function testPlayTurnAndVerifyImpactFirstTurnNotPlayed() public gameCreated {
        ImpactProof memory impactProof = boardConfiguration.getHitImpactProof();

        vm.expectRevert("It is the first turn, please call `playFirstTurn` instead");
        battleshipManager.playTurnAndVerifyImpact(0, [0, 0], impactProof);
    }

    function testPlayTurnAndVerifyImpactInvalidPlayer() public gameCreated firstTurnPlayed(0, 0) {
        ImpactProof memory impactProof = boardConfiguration.getHitImpactProof();

        vm.prank(PLAYER1);
        vm.expectRevert("Not your turn");
        battleshipManager.playTurnAndVerifyImpact(0, [0, 0], impactProof);
    }

    function testPlayTurnAndVerifyImpactInvalidOutput() public gameCreated firstTurnPlayed(2, 8) {
        ImpactProof memory impactProof = boardConfiguration.getHitImpactProof();
        // Change from hit to miss.
        impactProof.input[0] = 0;

        vm.prank(PLAYER2);
        vm.expectRevert("Impact proof is invalid");
        battleshipManager.playTurnAndVerifyImpact(0, [0, 0], impactProof);
    }

    function testPlayTurnAndVerifyImpactInvalidCommitment() public gameCreated firstTurnPlayed(2, 8) {
        ImpactProof memory impactProof = boardConfiguration.getHitImpactProof();
        // Change the commitment
        impactProof.input[1] += 1;

        vm.prank(PLAYER2);
        vm.expectRevert("Board commitment used in proof is invalid");
        battleshipManager.playTurnAndVerifyImpact(0, [0, 0], impactProof);
    }

    function testPlayTurnAndVerifyImpactInvalidXCoordinate() public gameCreated firstTurnPlayed(2, 8) {
        ImpactProof memory impactProof = boardConfiguration.getHitImpactProof();
        // Change the x coordinate
        impactProof.input[2] += 1;

        vm.prank(PLAYER2);
        vm.expectRevert("Invalid x-coordinate");
        battleshipManager.playTurnAndVerifyImpact(0, [0, 0], impactProof);
    }

    function testPlayTurnAndVerifyImpactInvalidYCoordinate() public gameCreated firstTurnPlayed(2, 8) {
        ImpactProof memory impactProof = boardConfiguration.getHitImpactProof();
        // Change the y coordinate
        impactProof.input[3] += 1;

        vm.prank(PLAYER2);
        vm.expectRevert("Invalid y-coordinate");
        battleshipManager.playTurnAndVerifyImpact(0, [0, 0], impactProof);
    }

    function testPlayTurnAndVerifyImpactHit() public gameCreated firstTurnPlayed(2, 8) {
        ImpactProof memory impactProof = boardConfiguration.getHitImpactProof();

        vm.prank(PLAYER2);
        battleshipManager.playTurnAndVerifyImpact(0, [5, 4], impactProof);

        Game memory game = battleshipManager.getGame(0);
        assert(Tile.HIT == game.player2.visibleBoard[2][8]);
        assertEq(16, game.player2.healthRemaining);

        assertEq(PLAYER1, game.turn.player);
        assertEq(5, game.turn.lastMove[0]);
        assertEq(4, game.turn.lastMove[1]);
        assertEq(address(0), game.winner);
    }

    function testPlayTurnAndVerifyImpactMiss() public gameCreated firstTurnPlayed(4, 3) {
        ImpactProof memory impactProof = boardConfiguration.getMissImpactProof();

        vm.prank(PLAYER2);
        battleshipManager.playTurnAndVerifyImpact(0, [5, 4], impactProof);

        Game memory game = battleshipManager.getGame(0);
        assert(Tile.MISS == game.player2.visibleBoard[4][3]);
        assertEq(17, game.player2.healthRemaining);

        assertEq(PLAYER1, game.turn.player);
        assertEq(5, game.turn.lastMove[0]);
        assertEq(4, game.turn.lastMove[1]);
        assertEq(address(0), game.winner);
    }

    function assertTurnIsValid(address player, Turn memory turn) private {
        assertEq(player, turn.player);
        assertEq(0, turn.lastMove[0]);
        assertEq(0, turn.lastMove[1]);
        assertEq(true, turn.isFirstTurn);
    }

    function assertPlayerIsValid(address expectedFirstTurnPlayer, Player memory createdPlayer, uint256 boardCommitment)
        private
    {
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
