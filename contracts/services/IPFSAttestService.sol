// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {BaseAttestService} from "../BaseAttestService.sol";
import {AttestType, Attest} from "../interfaces/IAttestService.sol";
import {Errors} from "../libraries/Errors.sol";

contract IPFSAttestService is BaseAttestService {
    constructor(address registry) BaseAttestService(registry) {}

    function getAttestType() external pure override returns (AttestType) {
        return AttestType.IPFS;
    }

    function onAttest(Attest calldata) internal view override returns (bool) {
        if (throwable) revert Errors.ToBeDetermined();
        return true;
    }

    function onRevoke(Attest calldata) internal view override returns (bool) {
        if (throwable) revert Errors.ToBeDetermined();
        return true;
    }
}
