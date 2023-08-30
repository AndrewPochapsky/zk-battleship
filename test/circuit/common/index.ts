import { Circomkit, WitnessTester } from "circomkit";
import { SignalValueType } from "circomkit/dist/types/circuit";

export type Board = {
  patrol_location: number[][];
  sub_location: number[][];
  destroyer_location: number[][];
  battleship_location: number[][];
  carrier_location: number[][];
  secret: number;
};

export const circomkit = new Circomkit({
  verbose: false,
});

export async function generateCommitment(
  board: Board
): Promise<SignalValueType> {
  let commitCircuit: WitnessTester<
    [
      "patrol_location",
      "sub_location",
      "destroyer_location",
      "battleship_location",
      "carrier_location",
      "secret"
    ],
    ["out"]
  > = await circomkit.WitnessTester("generate_board_commitment", {
    file: "commit",
    template: "GenerateBoardCommitment",
    params: [],
  });

  const commitment = await commitCircuit.compute(board, ["out"]);
  return commitment.out;
}
