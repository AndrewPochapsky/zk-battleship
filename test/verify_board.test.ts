import { WitnessTester } from "circomkit";
import { circomkit, generateCommitment } from "./common";

describe("Test Verify Board", () => {
  let circuit: WitnessTester<
    [
      "board",
      "patrol_location",
      "sub_location",
      "destroyer_location",
      "battleship_location",
      "carrier_location",
      "secret"
    ],
    ["board_commitment"]
  >;

  before(async () => {
    circuit = await circomkit.WitnessTester(`verify_board`, {
      file: "verify_board",
      template: "VerifyBoard",
      params: [],
    });
    console.log("#constraints:", await circuit.getConstraintCount());
  });

  it("should be valid", async () => {
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

    const commitment = await generateCommitment(board, secret);

    await circuit.expectPass(
      {
        board: board,
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
        secret: secret,
      },
      { board_commitment: commitment }
    );
  });

  it("missing ship, should fail", async () => {
    await circuit.expectFail({
      board: [
        [1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 4, 0, 0, 3, 3, 3, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 5],
      ],
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
      secret: 0,
    });
  });

  it("invalid sea tile value, should fail", async () => {
    await circuit.expectFail({
      board: [
        [1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
        [0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 4, 0, 0, 3, 3, 3, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 5],
      ],
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
      secret: 0,
    });
  });

  it("out of bounds location, should fail", async () => {
    await circuit.expectFail({
      board: [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
        [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
        [0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 4, 0, 0, 3, 3, 3, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 5],
      ],
      patrol_location: [
        [0, 9],
        [0, 10],
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
      secret: 0,
    });
  });

  it("miss-alignment, should fail", async () => {
    await circuit.expectFail({
      board: [
        [1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 0, 0, 0, 0, 2, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
        [0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 4, 0, 0, 3, 3, 3, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 5],
      ],
      patrol_location: [
        [0, 0],
        [1, 1],
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
      secret: 0,
    });
  });

  it("invalid ship length, should fail", async () => {
    await circuit.expectFail({
      board: [
        [1, 1, 1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
        [0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 4, 0, 0, 3, 3, 3, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 5],
      ],
      patrol_location: [
        [0, 0],
        [0, 2],
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
      secret: 0,
    });
  });

  it("location and board mismatch, should fail", async () => {
    await circuit.expectFail({
      board: [
        [0, 0, 1, 1, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 2, 0],
        [0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 4, 0, 0, 3, 3, 3, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 4, 0, 0, 0, 0, 0, 0, 0, 5],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 5],
      ],
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
      secret: 0,
    });
  });
});
