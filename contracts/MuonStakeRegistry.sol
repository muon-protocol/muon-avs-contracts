// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import {ISignatureUtils} from "eigenlayer-contracts/src/contracts/interfaces/ISignatureUtils.sol";
import {IDelegationManager} from "eigenlayer-contracts/src/contracts/interfaces/IDelegationManager.sol";
import {ECDSAStakeRegistry} from "eigenlayer/src/unaudited/ECDSAStakeRegistry.sol";
import {IMuonServiceManager} from "./interfaces/IMuonServiceManager.sol";

/// @title MUON Stake Registry
contract MuonStakeRegistry is ECDSAStakeRegistry {
    constructor(
        IDelegationManager _delegationManager
    ) ECDSAStakeRegistry(_delegationManager) {
        _disableInitializers();
    }

    /// @notice request to exit AVS
    function requestExit() external {
        IMuonServiceManager(_serviceManager).requestExit(msg.sender);
    }

    function setServiceManager(address _serviceManagerAddr) external onlyOwner {
        _serviceManager = _serviceManagerAddr;
    }
}
