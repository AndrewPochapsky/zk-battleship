// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

contract MockVerifyImpactVerifier {
    function verifyProof(uint256[2] memory, uint256[2][2] memory, uint256[2] memory, uint256[4] memory)
        public
        pure
        returns (bool r)
    {
        return true;
    }
}
