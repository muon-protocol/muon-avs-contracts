// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {SignatureChecker} from "openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

library EigenLayerVerifier {
    using SignatureChecker for address;

    /// @notice Validates a given signature against the signer's address and data hash.
    /// @param _signer The address of the signer to validate.
    /// @param _dataHash The hash of the data that is signed.
    /// @param _signature The signature to validate.
    function _validateSignature(
        address _signer,
        bytes32 _dataHash,
        bytes memory _signature
    ) internal view {
        if (!_signer.isValidSignatureNow(_dataHash, _signature)) {
            revert("Invalid EigenLayer signature!");
        }
    }
}
