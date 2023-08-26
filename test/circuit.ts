import { WitnessTester } from "circomkit";
import { circomkit } from "./common";

describe("Test Main", () => {
  let circuit: WitnessTester<
    [
      "board",
      "patrol_location",
      "sub_location",
      "destroyer_location",
      "battleship_location",
      "carrier_location"
    ]
  >;

  before(async () => {
    circuit = await circomkit.WitnessTester(`main`, {
      file: "circuit",
      template: "Main",
      params: [],
    });
    console.log("#constraints:", await circuit.getConstraintCount());
  });

  it("should be valid", async () => {
    await circuit.expectPass({
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
    });
  });
});
