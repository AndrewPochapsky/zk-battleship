pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/comparators.circom";
include "./utils.circom";
include "./commit.circom";

template VerifyImpact() {
    signal input board[10][10];
    signal input coordinate[2];
    signal input board_commitment;
    signal input secret;
    signal output is_hit;

    // Verify the board commitment.
    component generate_board_commitment = GenerateBoardCommitment();
    generate_board_commitment.board <== board;
    generate_board_commitment.secret <== secret;
    generate_board_commitment.out === board_commitment;

    component x_is_equal[10];
    component y_is_equal[10];

    for (var i = 0; i < 10; i++) {
        x_is_equal[i] = IsEqual();
        x_is_equal[i].in[0] <== i;
        x_is_equal[i].in[1] <== coordinate[0];

        y_is_equal[i] = IsEqual();
        y_is_equal[i].in[0] <== i;
        y_is_equal[i].in[1] <== coordinate[1];
    }

    signal coordinate_is_equal[10][10];

    // Extract the coordinate.
    component calc_total = CalculateTotal(100);
    var index = 0;
    for (var i = 0; i < 10; i++) {
        for (var j = 0; j < 10; j++) {
            coordinate_is_equal[i][j] <== x_is_equal[i].out * y_is_equal[j].out;
            calc_total.in[index] <== board[i][j] * coordinate_is_equal[i][j];
            index++;
        }
    }

    component greater_than = GreaterThan(4);
    greater_than.in[0] <== calc_total.out;
    greater_than.in[1] <== 0;

    is_hit <== greater_than.out;
}
