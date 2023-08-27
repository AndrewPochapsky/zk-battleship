pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/poseidon.circom";

template GenerateBoardCommitment() {
    signal input board[10][10];
    signal input secret;
    signal output out;

    component hashers[10];

    var previousHash = secret;
    for (var i = 0; i < 10; i++) {
        hashers[i] = Poseidon(10);
        for (var j = 0; j < 10; j++) {
            hashers[i].inputs[j] <== board[i][j] + previousHash;
        }
        previousHash = hashers[i].out;
    }
    out <== hashers[9].out;
}
