// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IAttestService, AttestType, Attest} from "./IAttestService.sol";

interface IAttestRegistry {
    function register(
        AttestType,
        address,
        bool
    ) external;

    function attest(AttestType _type, Attest calldata _attest) external;

    function revoke(AttestType _type, Attest calldata _attest) external;

    function getAttestService(AttestType _type) external view returns (address);
}
