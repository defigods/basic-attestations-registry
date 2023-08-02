// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {BaseAttestService} from "../BaseAttestService.sol";
import {AttestType, Attest} from "../interfaces/IAttestService.sol";
import {Errors} from "../libraries/Errors.sol";

import "hardhat/console.sol";

contract SBTAttestService is BaseAttestService {
    constructor(address registry) BaseAttestService(registry) {}

    function getAttestType() external pure override returns (AttestType) {
        return AttestType.SBT;
    }

    function onAttest(Attest calldata attest) internal view override {
        address addr;
        bytes memory key = attest.key;
        assembly {
            addr := mload(add(key, 20))
        }
        console.log(addr);
    }

    function onRevoke(Attest calldata) internal view override {
        if (throwable) revert Errors.ToBeDetermined();
    }
}
