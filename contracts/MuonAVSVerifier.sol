// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IMuonClient.sol";
import "./libs/EigenLayerVerifier.sol";

contract MuonAVSVerifier is AccessControl {
    using MessageHashUtils for bytes32;

    struct App {
        address owner;
        IMuonClient.PublicKey muonPublicKey;
        address[] operators;
    }

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant REGISTRAR_ROLE = keccak256("REGISTRAR_ROLE");

    IMuonClient muon;

    mapping(uint256 => App) public apps;
    mapping(address => bool) public operators;

    event OperatorRegistered(address operator);
    event OperatorRemoved(address operator);
    event AppRegistered(
        uint256 appId,
        address owner,
        IMuonClient.PublicKey muonPublicKey
    );
    event AppRemoved(uint256 appId);
    event SignatureVerified(
        uint256 appId,
        bytes reqId,
        address operator,
        bytes signature
    );
    event OwnershipTransfered(uint256 appId, address owner);
    event AppPubKeyChanged(uint256 appId, IMuonClient.PublicKey muonPublicKey);
    event AppOperatorsChanged(uint256 appId);

    constructor(address _muon) AccessControl() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(REGISTRAR_ROLE, msg.sender);

        muon = IMuonClient(_muon);
    }

    /**
     * @notice Register an app to use AVS
     * @param _appId App ID on the MUON network
     * @param _owner App owner
     * @param _muonPublicKey App PubKey on the MUON network
     * @param _operators Leave it empty if each operator can verify the signature
     */
    function registerApp(
        uint256 _appId,
        address _owner,
        IMuonClient.PublicKey memory _muonPublicKey,
        address[] memory _operators
    ) external onlyRole(REGISTRAR_ROLE) {
        require(apps[_appId].owner == address(0), "Already registered!");

        for (uint i = 0; i < _operators.length; i++) {
            require(operators[_operators[i]], "Invalid operator");
        }

        App storage newApp = apps[_appId];
        newApp.owner = _owner;
        newApp.muonPublicKey = _muonPublicKey;
        newApp.operators = _operators;

        emit AppRegistered(_appId, _owner, _muonPublicKey);
    }

    /**
     * @notice Register an operator on the AVS
     * @param _operator Operator address
     */
    function registerOperator(
        address _operator
    ) external onlyRole(REGISTRAR_ROLE) {
        require(!operators[_operator], "Already added");
        operators[_operator] = true;

        emit OperatorRegistered(_operator);
    }

    /**
     * @notice Deregister an operator from the AVS
     * @param _operator Operator address
     */
    function removeOperator(
        address _operator
    ) external onlyRole(REGISTRAR_ROLE) {
        require(operators[_operator], "Invalid operator");
        delete operators[_operator];

        emit OperatorRemoved(_operator);
    }

    /**
     * @notice Can be called only by the app's owner
     * @param _appId App ID on the MUON network
     * @param newOwner Address of the new owner
     */
    function transferAppOwnership(uint256 _appId, address newOwner) external {
        require(apps[_appId].owner == msg.sender, "Permission denied!");

        apps[_appId].owner = newOwner;

        emit OwnershipTransfered(_appId, newOwner);
    }

    /**
     * @notice Can be called only by the app's owner
     * @param _appId App ID on the MUON network
     * @param _muonPublicKey App PubKey on the MUON network
     */
    function setAppPublicKey(
        uint256 _appId,
        IMuonClient.PublicKey memory _muonPublicKey
    ) external {
        require(apps[_appId].owner == msg.sender, "Permission denied!");

        apps[_appId].muonPublicKey = _muonPublicKey;

        emit AppPubKeyChanged(_appId, _muonPublicKey);
    }

    /**
     * @notice Can be called only by the app's owner
     * @param _appId App ID on the MUON network
     * @param _operators List of operators
     */
    function setAppOperators(
        uint256 _appId,
        address[] memory _operators
    ) external {
        require(apps[_appId].owner == msg.sender, "Permission denied!");

        apps[_appId].operators = _operators;

        emit AppOperatorsChanged(_appId);
    }

    /**
     * @notice Can be called only by the app's owne
     * @param _appId App ID on the MUON network
     */
    function removeApp(uint256 _appId) external {
        require(apps[_appId].owner == msg.sender, "Permission denied!");

        delete apps[_appId];

        emit AppRemoved(_appId);
    }

    function verifySig(
        uint256 appId,
        bytes calldata reqId,
        bytes32 hash,
        IMuonClient.SchnorrSign calldata sign,
        address operator,
        bytes calldata signature
    ) external {
        require(isValidOperator(appId, operator), "Invalid operator");
        require(apps[appId].muonPublicKey.x != 0, "App is not configured");

        bool verified = muon.muonVerify(
            reqId,
            uint256(hash),
            sign,
            apps[appId].muonPublicKey
        );
        require(verified, "Invalid MUON signature!");
        EigenLayerVerifier._validateSignature(
            operator,
            hash.toEthSignedMessageHash(),
            signature
        );

        emit SignatureVerified(appId, reqId, operator, signature);
    }

    function getAppOperators(
        uint256 _appId
    ) external view returns (address[] memory _operators) {
        _operators = apps[_appId].operators;
    }

    function isValidOperator(
        uint256 _appId,
        address operator
    ) internal view returns (bool) {
        if (!operators[operator]) return false;

        if (apps[_appId].operators.length != 0) {
            bool isValid = false;
            for (uint i = 0; i < apps[_appId].operators.length; i++) {
                if (apps[_appId].operators[i] == operator) {
                    isValid = true;
                    break;
                }
            }
            return isValid;
        }

        return true;
    }
}
