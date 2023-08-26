pragma circom 2.1.4;

include "../node_modules/circomlib/circuits/gates.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template Main() {
    signal input board[10][10];
    signal input patrol_location[2][2]; //  [0, 0], [0, 1] is the start location | [1, 0], [1, 1] is the end location.
    signal input sub_location[2][2];
    signal input destroyer_location[2][2];
    signal input battleship_location[2][2];
    signal input carrier_location[2][2];

    component verify_board = VerifyBoard();
    verify_board.board <== board;
    verify_board.patrol_location <== patrol_location;
    verify_board.sub_location <== sub_location;
    verify_board.destroyer_location <== destroyer_location;
    verify_board.battleship_location <== battleship_location;
    verify_board.carrier_location <== carrier_location;
}

/*
    Board configuration:
    10 x 10 grid of field elements.
    0 -> water
    1 -> patrol boat
    2 -> submarine
    3 -> destroyer
    4 -> battleship
    5 -> carrier
*/
template VerifyBoard() {
    signal input board[10][10];
    signal input patrol_location[2][2]; //  [0, 0], [0, 1] is the start location | [1, 0], [1, 1] is the end location.
    signal input sub_location[2][2];
    signal input destroyer_location[2][2];
    signal input battleship_location[2][2];
    signal input carrier_location[2][2];

    component verify_patrol = VerifyBoatLocation(2, 1);
    verify_patrol.board <== board;
    verify_patrol.location <== patrol_location;

    component verify_sub = VerifyBoatLocation(3, 2);
    verify_sub.board <== board;
    verify_sub.location <== sub_location;

    component verify_destroyer = VerifyBoatLocation(3, 3);
    verify_destroyer.board <== board;
    verify_destroyer.location <== destroyer_location;

    component verify_battleship = VerifyBoatLocation(4, 4);
    verify_battleship.board <== board;
    verify_battleship.location <== battleship_location;

    component verify_carrier = VerifyBoatLocation(5, 5);
    verify_carrier.board <== board;
    verify_carrier.location <== carrier_location;

    // Verify sea tiles are 0
    component condition[10][10];
    component is_sea_tile[10][10];
    for (var i = 0; i < 10; i++) {
        for (var j = 0; j < 10; j++) {
            var sum = verify_patrol.mask[i][j] + verify_sub.mask[i][j] + verify_destroyer.mask[i][j];
            is_sea_tile[i][j] = IsZero();
            is_sea_tile[i][j].in <== sum;

            condition[i][j] = IfThenElse();
            condition[i][j].cond <== is_sea_tile[i][j].out;
            condition[i][j].L <== 1;
            condition[i][j].R <== 0;

            board[i][j] * is_sea_tile[i][j].out === condition[i][j].out;
        }
    }
}

/*
 * `out` = `cond` ? `L` : `R`
 */
template IfThenElse() {
    signal input cond;
    signal input L;
    signal input R;
    signal output out;

    out <== cond * (L - R) + R;
}

template VerifyBoatLocation(boat_length, marker) {
    signal input location[2][2];
    signal input board[10][10];
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

    horizontal_length_equal.in[0] <== end_y - start_y;
    horizontal_length_equal.in[1] <== boat_length;

    vertical_length_equal.in[0] <== end_x - start_x;
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

    // [i][j] == marker if boat is in that location, 0 otherwise.
    //signal mask[10][10];
    for (var i = 0; i < 10; i++) {
        for (var j = 0; j < 10; j++) {
            mask[i][j] <== x_in_range[i] * y_in_range[j] * marker;
            board[i][j] === mask[i][j];
        }
    }
}

component main = Main();
