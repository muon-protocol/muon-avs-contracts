// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

library EigenLayerVerifier {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    function _validateSignature(
        address operator,
        bytes32 hash,
        bytes calldata signature
    ) internal pure {
        hash = hash.toEthSignedMessageHash();
        address signatureSigner = hash.recover(signature);

        require(signatureSigner == operator, "Invalid EigenLayer signature!");
    }
}
