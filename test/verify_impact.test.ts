import { WitnessTester } from "circomkit";
import { circomkit, generateCommitment } from "./common";

describe("Test Verify Impact", () => {
  let circuit: WitnessTester<
    ["board", "coordinate", "board_commitment", "secret"],
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
    let board: number[][] = [
      [1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 4, 0, 0, 3, 3, 3, 0, 0, 5],
      [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
      [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
      [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 5],
    ];
    let secret = 42;

    let commitment = await generateCommitment(board, secret);

    await circuit.expectPass(
      {
        board: board,
        coordinate: [0, 0],
        board_commitment: commitment,
        secret: secret,
      },
      { is_hit: 1 }
    );
  });

  it("is miss", async () => {
    let board: number[][] = [
      [1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 4, 0, 0, 3, 3, 3, 0, 0, 5],
      [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
      [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
      [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 5],
    ];
    let secret = 42;

    let commitment = await generateCommitment(board, secret);

    await circuit.expectPass(
      {
        board: board,
        coordinate: [1, 0],
        board_commitment: commitment,
        secret: secret,
      },
      { is_hit: 0 }
    );
  });

  it("invalid board, should fail", async () => {
    let board: number[][] = [
      [1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 4, 0, 0, 3, 3, 3, 0, 0, 5],
      [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
      [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
      [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 5],
    ];
    let secret = 42;

    let commitment = await generateCommitment(board, secret);

    // Change the board.
    board[0][0] = 0;

    await circuit.expectFail({
      board: board,
      coordinate: [0, 0],
      board_commitment: commitment,
      secret: secret,
    });
  });

  it("invalid secret, should fail", async () => {
    let board: number[][] = [
      [1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 4, 0, 0, 3, 3, 3, 0, 0, 5],
      [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
      [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
      [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 5],
    ];
    let secret = 42;

    let commitment = await generateCommitment(board, secret);

    await circuit.expectFail({
      board: board,
      coordinate: [0, 0],
      board_commitment: commitment,
      secret: secret + 1,
    });
  });
});
