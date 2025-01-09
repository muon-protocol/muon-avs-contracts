// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "eigenlayer/src/unaudited/ECDSAServiceManagerBase.sol";

/**
 * @title Primary entrypoint for procuring services from MuonAVS.
 * @author Layr Labs, Inc.
 */
contract ServiceManager is ECDSAServiceManagerBase {
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

    function initialize() external initializer {
        __ServiceManager_init();
    }

    function __ServiceManager_init() internal onlyInitializing {
        __Ownable_init();
        __ServiceManager_init_unchained();
    }

    function __ServiceManager_init_unchained() internal onlyInitializing {}
}
