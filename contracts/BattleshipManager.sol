// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import {Verifier as VerifyBoardVerifier} from "./VerifyBoardVerifier.sol";
import {Verifier as VerifyImpactVerifier} from "./VerifyImpactVerifier.sol";

import {Game, BoardProof, Player, Turn, ImpactProof, Tile, createGameStruct} from "./Structs.sol";

contract BattleshipManager {
    VerifyBoardVerifier private s_verifyBoardVerifier;
    VerifyImpactVerifier private s_verifyImpactVerifier;

    Game[] private s_games;

    constructor(address verifyBoardVerifier, address verifyImpactVerifier) {
        s_verifyBoardVerifier = VerifyBoardVerifier(verifyBoardVerifier);
        s_verifyImpactVerifier = VerifyImpactVerifier(verifyImpactVerifier);
    }

    function createGame(address player1, BoardProof memory boardProof1, address player2, BoardProof memory boardProof2)
        public
    {
        require(player1 != player2, "Player1 and Player2 must be different");

        bool firstProofValid =
            s_verifyBoardVerifier.verifyProof(boardProof1.a, boardProof1.b, boardProof1.c, boardProof1.input);
        require(firstProofValid, "Player 1's proof is invalid");

        bool secondProofValid =
            s_verifyBoardVerifier.verifyProof(boardProof2.a, boardProof2.b, boardProof2.c, boardProof2.input);
        require(secondProofValid, "Player 2's proof is invalid");

        Game memory game = createGameStruct(player1, boardProof1, player2, boardProof2);
        s_games.push(game);
    }

    function playFirstTurn(uint256 gameIndex, uint8[2] memory coordinate) public {
        Game memory game = getGame(gameIndex);
        require(game.turn.isFirstTurn, "It is not the first turn");
        require(game.turn.player == msg.sender, "Not your turn");
        require(coordinateIsValid(coordinate), "Coordinate is not valid");

        game.turn.lastMove = coordinate;
        game.turn.isFirstTurn = false;
        game.turn.player = getNextTurnPlayer(game);

        s_games[gameIndex] = game;
    }

    function playTurnAndVerifyImpact(uint256 gameIndex, uint8[2] memory coordinate, ImpactProof memory impactProof) public {
        Game memory game = getGame(gameIndex);
        require(!game.turn.isFirstTurn, "It is the first turn, please call `playFirstTurn` instead");
        require(game.turn.player == msg.sender, "Not your turn");

        // verify the impact proof
        Player memory player = getPlayerFromAddress(game, game.turn.player);
        Turn memory turn = game.turn;
        verifyImpactProof(player, turn, impactProof);

        bool isHit = impactProof.input[0] == 1;

        Tile tile = isHit ? Tile.HIT : Tile.MISS;
        player.visibleBoard[turn.lastMove[0]][turn.lastMove[1]] = tile;

        if (isHit) {
            game = handleHit(player, game);
        }

        // If game did not end as a result of the last move, keep playing.
        if (game.winner == address(0)) {
            require(coordinateIsValid(coordinate), "Coordinate is not valid");
            game.turn.lastMove = coordinate;
            game.turn.player = getNextTurnPlayer(game);
        }

        s_games[gameIndex] = game;
    }

    function getGame(uint256 index) public view returns (Game memory) {
        return s_games[index];
    }

    function handleHit(Player memory player, Game memory game) private pure returns (Game memory updatedGame) {
        address nextTurnPlayer = getNextTurnPlayer(game);
        player.healthRemaining -= 1;
        if (player.healthRemaining == 0) {
            game.winner = nextTurnPlayer;
            return game;
        }
    }

    function verifyImpactProof(Player memory player, Turn memory turn, ImpactProof memory impactProof) private view {
        require(player.boardCommitment == impactProof.input[1], "Board commitment used in proof is invalid");
        require(turn.lastMove[0] == impactProof.input[2], "Invalid x-coordinate");
        require(turn.lastMove[1] == impactProof.input[3], "Invalid y-coordinate");
        bool proofIsValid = s_verifyImpactVerifier.verifyProof(impactProof.a, impactProof.b, impactProof.c, impactProof.input);
        require(proofIsValid, "Impact proof is invalid");
    }

    function getNextTurnPlayer(Game memory game) private pure returns (address) {
        if (game.turn.player != game.player1.player) {
            return game.player1.player;
        }
        return game.player2.player;
    }

    function getPlayerFromAddress(Game memory game, address playerAddress) private pure returns (Player memory) {
        if (game.player1.player == playerAddress) {
            return game.player1;
        }
        return game.player2;
    }

    function coordinateIsValid(uint8[2] memory coordinate) private pure returns (bool) {
        for (uint8 i = 0; i < 2; i++) {
            if (coordinate[i] >= 10) {
                return false;
            }
        }
        return true;
    }
}
