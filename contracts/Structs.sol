// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

struct Game {
    Player player1;
    Player player2;
    address turn;
    address winner;
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
