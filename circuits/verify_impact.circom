pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/comparators.circom";
include "./utils.circom";
include "./verify_board.circom";
include "./commit.circom";

template VerifyImpact() {
    signal input patrol_location[2][2];
    signal input sub_location[2][2];
    signal input destroyer_location[2][2];
    signal input battleship_location[2][2];
    signal input carrier_location[2][2];
    signal input secret;
    signal input board_commitment;
    signal input coordinate[2];

    signal output is_hit;

    // Verify the board commitment.
    component generate_board_commitment = GenerateBoardCommitment();
    generate_board_commitment.patrol_location <== patrol_location;
    generate_board_commitment.sub_location <== sub_location;
    generate_board_commitment.destroyer_location <== destroyer_location;
    generate_board_commitment.battleship_location <== battleship_location;
    generate_board_commitment.carrier_location <== carrier_location;
    generate_board_commitment.secret <== secret;
    generate_board_commitment.out === board_commitment;

    // Construct board. Since the commitment is valid we do not need
    // to validate all of the details again.
    component construct_board = ConstructBoard(/*should_validate=*/ 0);
    construct_board.patrol_location <== patrol_location;
    construct_board.sub_location <== sub_location;
    construct_board.destroyer_location <== destroyer_location;
    construct_board.battleship_location <== battleship_location;
    construct_board.carrier_location <== carrier_location;

    signal board[10][10] <== construct_board.board;

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

    component is_zero = IsZero();
    is_zero.in <== calc_total.out;

    is_hit <== 1 - is_zero.out;
}
