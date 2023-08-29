pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/gates.circom";
include "../node_modules/circomlib/circuits/comparators.circom";
include "./utils.circom";
include "./commit.circom";

template VerifyBoard() {
    signal input patrol_location[2][2];
    signal input sub_location[2][2];
    signal input destroyer_location[2][2];
    signal input battleship_location[2][2];
    signal input carrier_location[2][2];
    signal input secret; // Used to "salt" the commitment.
    signal output board_commitment; // A hash commitment to the board using Poseidon.

    component construct_board = ConstructBoard();
    construct_board.patrol_location <== patrol_location;
    construct_board.sub_location <== sub_location;
    construct_board.destroyer_location <== destroyer_location;
    construct_board.battleship_location <== battleship_location;
    construct_board.carrier_location <== carrier_location;

    component generate_board_commitment = GenerateBoardCommitment();
    generate_board_commitment.patrol_location <== patrol_location;
    generate_board_commitment.sub_location <== sub_location;
    generate_board_commitment.destroyer_location <== destroyer_location;
    generate_board_commitment.battleship_location <== battleship_location;
    generate_board_commitment.carrier_location <== carrier_location;
    generate_board_commitment.secret <== secret;

    board_commitment <== generate_board_commitment.out;
}

template ConstructBoard() {
    signal input patrol_location[2][2];
    signal input sub_location[2][2];
    signal input destroyer_location[2][2];
    signal input battleship_location[2][2];
    signal input carrier_location[2][2];

    signal output board[10][10];

    component verify_patrol = ConstructPositionMask(2);
    verify_patrol.location <== patrol_location;

    component verify_sub = ConstructPositionMask(3);
    verify_sub.location <== sub_location;

    component verify_destroyer = ConstructPositionMask(3);
    verify_destroyer.location <== destroyer_location;

    component verify_battleship = ConstructPositionMask(4);
    verify_battleship.location <== battleship_location;

    component verify_carrier = ConstructPositionMask(5);
    verify_carrier.location <== carrier_location;

    // Verify positions don't overlap
    for (var i = 0; i < 10; i++) {
        for (var j = 0; j < 10; j++) {
            // Each tile must be either 1 or 0.
            board[i][j] <== verify_patrol.mask[i][j] + verify_sub.mask[i][j] + verify_destroyer.mask[i][j] + verify_battleship.mask[i][j] + verify_carrier.mask[i][j];
            (board[i][j] - 1) * board[i][j] === 0;
        }
    }
}

template ConstructPositionMask(boat_length) {
    signal input location[2][2];
    signal output mask[10][10];

    // Assume the order of the points given is top-bottom left to right. For example
    // [1, 1] [1, 3] instead of [1, 3], [1, 1]
    signal start_x <== location[0][0];
    signal start_y <== location[0][1];
    signal end_x <== location[1][0];
    signal end_y <== location[1][1];

    // Verify alignment
    // either start_x == end_x or start_y == end_y
    component x_are_equal = IsEqual();
    component y_are_equal = IsEqual();

    x_are_equal.in[0] <== start_x;
    x_are_equal.in[1] <== end_x;

    y_are_equal.in[0] <== start_y;
    y_are_equal.in[1] <== end_y;

    component are_aligned = XOR();
    are_aligned.a <== x_are_equal.out;
    are_aligned.b <== y_are_equal.out;
    are_aligned.out === 1;

    // Verify boat length
    component horizontal_length_equal = IsEqual();
    component vertical_length_equal = IsEqual();

    horizontal_length_equal.in[0] <== end_y - start_y + 1;
    horizontal_length_equal.in[1] <== boat_length;

    vertical_length_equal.in[0] <== end_x - start_x + 1;
    vertical_length_equal.in[1] <== boat_length;

    component length_matches = XOR();
    length_matches.a <== horizontal_length_equal.out;
    length_matches.b <== vertical_length_equal.out;
    length_matches.out === 1;

    // Verify position on board.
    component greater_eq_than_lower_x[10];
    component less_eq_than_upper_x[10];

    component greater_eq_than_lower_y[10];
    component less_eq_than_upper_y[10];

    signal x_in_range[10];
    signal y_in_range[10];

    for (var i = 0; i < 10; i++) {
        greater_eq_than_lower_x[i] = GreaterEqThan(4);
        greater_eq_than_lower_x[i].in[0] <== i;
        greater_eq_than_lower_x[i].in[1] <== start_x;

        less_eq_than_upper_x[i] = LessEqThan(4);
        less_eq_than_upper_x[i].in[0] <== i;
        less_eq_than_upper_x[i].in[1] <== end_x;

        greater_eq_than_lower_y[i] = GreaterEqThan(4);
        greater_eq_than_lower_y[i].in[0] <== i;
        greater_eq_than_lower_y[i].in[1] <== start_y;

        less_eq_than_upper_y[i] = LessEqThan(4);
        less_eq_than_upper_y[i].in[0] <== i;
        less_eq_than_upper_y[i].in[1] <== end_y;

        x_in_range[i] <== greater_eq_than_lower_x[i].out * less_eq_than_upper_x[i].out;
        y_in_range[i] <== greater_eq_than_lower_y[i].out * less_eq_than_upper_y[i].out;
    }
    var sum = 0;
    for (var i = 0; i < 10; i++) {
        for (var j = 0; j < 10; j++) {
            mask[i][j] <== x_in_range[i] * y_in_range[j];
            sum += mask[i][j];
        }
    }
    // Avoids any out of bound coordinates.
    sum === boat_length;
}
