// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "eigenlayer/src/unaudited/ECDSAServiceManagerBase.sol";
import "eigenlayer/src/unaudited/ECDSAStakeRegistry.sol";

/**
 * @title Primary entrypoint for procuring services from MuonAVS.
 * @author Layr Labs, Inc.
 */
contract MuonServiceManager is ECDSAServiceManagerBase {
    // The waiting period to let operators deregister
    uint256 public exitPendingPeriod;

    /**
     * operator address => time
     * @notice maps operator addresses to time when they have
     * When operatos haved exited.
     * Then time when operatos can deregister is exit time + pending period
     */
    mapping(address => uint256) public operatorsExitTime;

    event OperatorRequestExit(address operator);

    constructor(
        address _avsDirectory,
        address _stakeRegistry,
        address _rewardsCoordinator,
        address _delegationManager
    )
        ECDSAServiceManagerBase(
            _avsDirectory,
            _stakeRegistry,
            _rewardsCoordinator,
            _delegationManager
        )
    {
        _disableInitializers();
    }

    function initialize(
        address _initialOwner,
        address _rewardsInitiator
    ) external initializer {
        __ServiceManager_init(_initialOwner, _rewardsInitiator);
    }

    function __ServiceManager_init(
        address _initialOwner,
        address _rewardsInitiator
    ) internal onlyInitializing {
        __ServiceManagerBase_init(_initialOwner, _rewardsInitiator);
        __ServiceManager_init_unchained();
    }

    function __ServiceManager_init_unchained() internal onlyInitializing {}

    function setExitPendingPeriod(uint256 period) external onlyOwner {
        exitPendingPeriod = period;
    }

    function requestExit(address _operator) external onlyStakeRegistry {
        require(
            ECDSAStakeRegistry(stakeRegistry).operatorRegistered(_operator),
            "Invalid operator"
        );
        operatorsExitTime[_operator] = block.timestamp;

        emit OperatorRequestExit(_operator);
    }

    /**
     * @inheritdoc ECDSAServiceManagerBase
     */
    function _deregisterOperatorFromAVS(
        address _operator
    ) internal virtual override {
        require(
            block.timestamp >= operatorsExitTime[_operator] + exitPendingPeriod,
            "Waiting period has not passed"
        );
        super._deregisterOperatorFromAVS(_operator);
    }
}
