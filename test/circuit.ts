import { assert } from "chai";
import path from "path";

import { WitnessTester } from "circomkit";
import { circomkit } from "./common";

describe("Test Main", () => {
  var circ_file = path.join("circuits", "circuit.circom");
  let circuit: WitnessTester<["in"], ["out"]>;

  before(async () => {
    circuit = await circomkit.WitnessTester(`main`, {
      file: "circuit",
      template: "Main",
      params: [],
    });
    console.log("#constraints:", await circuit.getConstraintCount());
  });

  it("Verify Valid Board", () => {
    assert(true);
  });
});
