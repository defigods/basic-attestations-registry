// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IRegistry} from "../interfaces/IRegistry.sol";

contract Mock {
    address private registry;

    constructor(address _registry) {
        registry = _registry;
    }

    function attest() external {
        IRegistry(registry).attest(IRegistry.AttestType.VC, registry, "", "");
    }
}
