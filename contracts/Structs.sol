// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

struct Game {
    Player player1;
    Player player2;
    Turn turn;
    address winner;
}

struct Turn {
    address player;
    uint8[2] lastMove;
    bool isFirstTurn;
}

enum Tile {
    UNKNOWN,
    HIT,
    MISS
}

struct Player {
    address player;
    uint256 boardCommitment;
    Tile[10][10] visibleBoard;
    uint8 healthRemaining;
}

struct BoardProof {
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
    uint256[1] input;
}

struct ImpactProof {
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
    uint256[4] input;
}

function createPlayerStruct(address player, uint256 boardCommitment) pure returns (Player memory) {
    Tile[10][10] memory emptyBoard;
    return Player({player: player, boardCommitment: boardCommitment, visibleBoard: emptyBoard, healthRemaining: 17});
}

function createGameStruct(
    address player1,
    BoardProof memory boardProof1,
    address player2,
    BoardProof memory boardProof2
) pure returns (Game memory) {
    return Game({
        player1: createPlayerStruct(player1, boardProof1.input[0]),
        player2: createPlayerStruct(player2, boardProof2.input[0]),
        turn: Turn({player: player1, lastMove: [0, 0], isFirstTurn: true}),
        winner: address(0)
    });
}
