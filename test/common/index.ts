import { Circomkit, WitnessTester } from "circomkit";
import { SignalValueType } from "circomkit/dist/types/circuit";

export const circomkit = new Circomkit({
  verbose: false,
});

export async function generateCommitment(
  board: number[][],
  secret: number
): Promise<SignalValueType> {
  let commitCircuit: WitnessTester<["board", "secret"], ["out"]> =
    await circomkit.WitnessTester("generate_board_commitment", {
      file: "commit",
      template: "GenerateBoardCommitment",
      params: [],
    });

  const commitment = await commitCircuit.compute(
    {
      board,
      secret,
    },
    ["out"]
  );
  return commitment.out;
}
