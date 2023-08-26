import { WitnessTester } from "circomkit";
import { circomkit } from "./common";

describe("Test Verify Impact", () => {
  let circuit: WitnessTester<["board", "coordinate"], ["is_hit"]>;

  before(async () => {
    circuit = await circomkit.WitnessTester(`verify_impact`, {
      file: "verify_impact",
      template: "VerifyImpact",
      params: [],
    });
    console.log("#constraints:", await circuit.getConstraintCount());
  });

  it("is hit", async () => {
    await circuit.expectPass(
      {
        board: [
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
        ],
        coordinate: [0, 0],
      },
      { is_hit: 1 }
    );
  });

  it("is miss", async () => {
    await circuit.expectPass(
      {
        board: [
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
        ],
        coordinate: [1, 0],
      },
      { is_hit: 0 }
    );
  });
});
