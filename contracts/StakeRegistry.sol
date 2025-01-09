// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {ISignatureUtils} from "eigenlayer-contracts/src/contracts/interfaces/ISignatureUtils.sol";
import {IDelegationManager} from "eigenlayer-contracts/src/contracts/interfaces/IDelegationManager.sol";
import {ECDSAStakeRegistry} from "eigenlayer/src/unaudited/ECDSAStakeRegistry.sol";

/// @title ECDSA Stake Registry
/// @notice This contract extends ECDSAStakeRegistry by adding functionality to remove operators
contract StakerRegistry is ECDSAStakeRegistry {
    /// @dev Emits when an operator is removed from the active operator set.
    event OperatorEjected(address indexed operator);

    constructor(
        IDelegationManager _delegationManager
    ) ECDSAStakeRegistry(_delegationManager) {
        _disableInitializers();
    }

    /// @notice Directly deregisters an operator
    /// @param _operator The address of the operator to deregister
    function ejectOperator(address _operator) external onlyOwner {
        _deregisterOperator(_operator);
        emit OperatorEjected(_operator);
    }
}
