pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/poseidon.circom";

template GenerateBoardCommitment() {
    signal input patrol_location[2][2];
    signal input sub_location[2][2];
    signal input destroyer_location[2][2];
    signal input battleship_location[2][2];
    signal input carrier_location[2][2];
    signal input secret;
    signal output out;

    component hashers[2];
    hashers[0] = Poseidon(11);
    hashers[1] = Poseidon(11);
    for (var i = 0; i < 2; i++) {
        hashers[i].inputs[0] <== patrol_location[i][0];
        hashers[i].inputs[1] <== patrol_location[i][1];
        hashers[i].inputs[2] <== sub_location[i][0];
        hashers[i].inputs[3] <== sub_location[i][1];
        hashers[i].inputs[4] <== destroyer_location[i][0];
        hashers[i].inputs[5] <== destroyer_location[i][1];
        hashers[i].inputs[6] <== battleship_location[i][0];
        hashers[i].inputs[7] <== battleship_location[i][1];
        hashers[i].inputs[8] <== carrier_location[i][0];
        hashers[i].inputs[9] <== carrier_location[i][1];
        hashers[i].inputs[10] <== secret;
    }

    component final_hash = Poseidon(2);
    for (var i = 0; i < 2; i++) {
        final_hash.inputs[i] <== hashers[i].out;
    }
    out <== final_hash.out;
}
