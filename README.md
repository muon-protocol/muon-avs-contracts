
# Muon AVS Contracts

## Overview
This repository contains the AVS smart contracts for the Muon Network on EigenLayer. These contracts manage the registration and deregistration of operators, as well as signature verification for Muon and EigenLayer.

## Contracts

### 1. **MuonServiceManager.sol**
   - Acts as the entry point for EigenLayer operators.
   - Forwards calls to register and deregister operators to the EigenLayer `AVSDirectory` contract.

### 2. **MuonStakeRegistry.sol**
   - Operators who wish to **deregister** must first **pass a pending period** defined by the AVS.
   - To deregister, the operator must:
     1. Call `requestExit()` on `MuonStakeRegistry.sol`.
     2. Wait for the pending period to pass.
     3. Then, proceed with deregistration.

### 3. **MuonAVSVerifier.sol**
   - Allows dApps running on Muon to verify **Muon** and **EigenLayer** signatures on any chain.
   - Ensures trustless verification for applications leveraging Muon and EigenLayer.

## License
MIT License. See LICENSE for details.
