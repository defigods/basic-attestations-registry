// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {AttestType, Attest} from "./interfaces/IAttestService.sol";
import {Errors} from "./libraries/Errors.sol";

abstract contract BaseAttestService is Ownable {
    address private _registry;
    bool public throwable;

    event Attested(address indexed attester, address indexed attestee, bytes key, bytes value);
    event Revoked(address indexed attester, address indexed attestee, bytes key, bytes value);

    modifier onlyRegistry() {
        if (msg.sender != _registry) revert Errors.NotRegistry();
        _;
    }

    constructor(address registry) {
        if (registry == address(0)) revert Errors.InvalidRegistry();
        _registry = registry;
    }

    function attest(Attest calldata _attest) external onlyRegistry {
        onAttest(_attest);
        emit Attested(msg.sender, _attest.recipient, _attest.key, _attest.value);
    }

    function revoke(Attest calldata _attest) external onlyRegistry {
        onRevoke(_attest);
        emit Revoked(msg.sender, _attest.recipient, _attest.key, _attest.value);
    }

    function setRegistry(address registry) external onlyOwner {
        _registry = registry;
    }

    function setThrowable(bool _throwable) external onlyOwner {
        throwable = _throwable;
    }

    function getRegistry() external view returns (address) {
        return _registry;
    }

    function getAttestType() external pure virtual returns (AttestType);

    function onAttest(Attest calldata attest) internal view virtual;

    function onRevoke(Attest calldata attest) internal view virtual;
}
