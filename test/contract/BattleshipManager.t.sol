// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {BattleshipManager} from "../../contracts/BattleshipManager.sol";

contract BattleshipManagerTest is Test {
    BattleshipManager public battleshipManager;

    function setUp() public {
        battleshipManager = new BattleshipManager();
    }
}
