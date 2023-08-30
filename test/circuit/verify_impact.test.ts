import { WitnessTester } from "circomkit";
import { circomkit, generateCommitment, Board } from "./common";

describe("Test Verify Impact", () => {
  let circuit: WitnessTester<
    [
      "patrol_location",
      "sub_location",
      "destroyer_location",
      "battleship_location",
      "carrier_location",
      "secret",
      "board_commitment",
      "coordinate"
    ],
    ["is_hit"]
  >;

  before(async () => {
    circuit = await circomkit.WitnessTester(`verify_impact`, {
      file: "verify_impact",
      template: "VerifyImpact",
      params: [],
    });
    console.log("#constraints:", await circuit.getConstraintCount());
  });

  it("is hit", async () => {
    let board: Board = {
      patrol_location: [
        [0, 0],
        [0, 1],
      ],
      sub_location: [
        [1, 8],
        [3, 8],
      ],
      destroyer_location: [
        [5, 4],
        [5, 6],
      ],
      battleship_location: [
        [5, 1],
        [8, 1],
      ],
      carrier_location: [
        [5, 9],
        [9, 9],
      ],
      secret: 42,
    };

    let commitment = await generateCommitment(board);

    await circuit.expectPass(
      {
        ...board,
        board_commitment: commitment,
        coordinate: [0, 0],
      },
      { is_hit: 1 }
    );
  });

  it("is miss", async () => {
    let board: Board = {
      patrol_location: [
        [0, 0],
        [0, 1],
      ],
      sub_location: [
        [1, 8],
        [3, 8],
      ],
      destroyer_location: [
        [5, 4],
        [5, 6],
      ],
      battleship_location: [
        [5, 1],
        [8, 1],
      ],
      carrier_location: [
        [5, 9],
        [9, 9],
      ],
      secret: 42,
    };

    let commitment = await generateCommitment(board);

    await circuit.expectPass(
      {
        ...board,
        board_commitment: commitment,
        coordinate: [1, 1],
      },
      { is_hit: 0 }
    );
  });

  it("invalid board, should fail", async () => {
    let board: Board = {
      patrol_location: [
        [0, 0],
        [0, 1],
      ],
      sub_location: [
        [1, 8],
        [3, 8],
      ],
      destroyer_location: [
        [5, 4],
        [5, 6],
      ],
      battleship_location: [
        [5, 1],
        [8, 1],
      ],
      carrier_location: [
        [5, 9],
        [9, 9],
      ],
      secret: 42,
    };

    let commitment = await generateCommitment(board);

    // Change the board.
    board.patrol_location[0][0] = 1;

    await circuit.expectFail({
      ...board,
      coordinate: [0, 0],
      board_commitment: commitment,
    });
  });

  it("invalid secret, should fail", async () => {
    let board: Board = {
      patrol_location: [
        [0, 0],
        [0, 1],
      ],
      sub_location: [
        [1, 8],
        [3, 8],
      ],
      destroyer_location: [
        [5, 4],
        [5, 6],
      ],
      battleship_location: [
        [5, 1],
        [8, 1],
      ],
      carrier_location: [
        [5, 9],
        [9, 9],
      ],
      secret: 42,
    };

    let commitment = await generateCommitment(board);

    board.secret += 1;

    await circuit.expectFail({
      ...board,
      coordinate: [0, 0],
      board_commitment: commitment,
    });
  });
});
