pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/poseidon.circom";

template GenerateBoardCommitment() {
    signal input board[10][10];
    signal input secret;
    signal output out;

    component hashers[11];
    hashers[0] = Poseidon(1);
    hashers[0].inputs[0] <== secret;

    var previousHash = hashers[0].out;
    for (var i = 0; i < 10; i++) {
        hashers[i + 1] = Poseidon(10);
        for (var j = 0; j < 10; j++) {
            hashers[i + 1].inputs[j] <== board[i][j] + previousHash;
        }
        previousHash = hashers[i + 1].out;
    }
    out <== hashers[10].out;
}
