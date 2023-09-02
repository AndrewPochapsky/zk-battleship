// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;

import {Script} from "forge-std/Script.sol";
import {Verifier as VerifyBoardVerifier} from "../contracts/VerifyBoardVerifier.sol";
import {BoardProof} from "../contracts/Structs.sol";

contract VerifyBoard is Script {
    function run() external {
        vm.startBroadcast();
        VerifyBoardVerifier verifier = new VerifyBoardVerifier();
        verifier.verifyProof(
            [
                uint256(6464719404952841404856722060112094631681371557279649410264072165808839739797),
                uint256(498056399369057604315708700262549333220631171189461324547835061042742942359)
            ],
            [
                [
                    uint256(4012422396631267962442360260409317580721760827401791228710857598897907792095),
                    uint256(1941808375998738832354754079368730759083632627556797268997947285286832633364)
                ],
                [
                    uint256(16435390779185989630085086491393986543051710124733835475628958004122634366061),
                    uint256(6961904062931652682086751781406145312368641344775167168673842544702622922106)
                ]
            ],
            [
                uint256(1641609360172235788336437142849479740768466400936263592312872034029407861109),
                uint256(4846782945058402916518537624529200163945312486747210355340109004793080731200)
            ],
            [uint256(20077887034440649463545446901862954011288754868170235875991998941563847407461)]
        );
        vm.stopBroadcast();
    }
}
