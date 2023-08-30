// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import {Verifier as VerifyBoardVerifier} from "./VerifyBoardVerifier.sol";
import {Verifier as VerifyImpactVerifier} from "./VerifyImpactVerifier.sol";

import {Game, BoardProof} from "./Structs.sol";

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
        bool firstProofValid =
            s_verifyBoardVerifier.verifyProof(boardProof1.a, boardProof1.b, boardProof1.c, boardProof1.input);
        require(firstProofValid, "Player 1's proof is invalid");

        bool secondProofValid =
            s_verifyBoardVerifier.verifyProof(boardProof2.a, boardProof2.b, boardProof2.c, boardProof2.input);
        require(secondProofValid, "Player 2's proof is invalid");
    }

    function getGame(uint256 index) public view returns (Game memory) {
        return s_games[index];
    }
}
