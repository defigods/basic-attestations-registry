// solhint-disable
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {BaseAttestService} from "../BaseAttestService.sol";
import {AttestType, Attest} from "../interfaces/IAttestService.sol";
import {Errors} from "../libraries/Errors.sol";

contract SBTAttestService is BaseAttestService {
    constructor(address registry) BaseAttestService(registry) {}

    function getAttestType() external pure override returns (AttestType) {
        return AttestType.SBT;
    }

    function onAttest(Attest calldata attest) internal view override returns (bool) {
        address addr;
        bytes memory key = attest.key;
        assembly {
            addr := mload(add(key, 20))
        }
        uint256 csize;
        assembly {
            csize := extcodesize(addr)
        }
        if (csize == 0) return false;

        try IERC165(addr).supportsInterface(type(IERC721).interfaceId) returns (bool ret) {
            return ret;
        } catch {
            return false;
        }
    }

    function onRevoke(Attest calldata) internal view override returns (bool) {
        if (throwable) revert Errors.ToBeDetermined();
        return true;
    }
}
