// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

library Errors {
    // Registry custom errors
    error ServiceAlreadyExists();
    error ServiceNotExists();
    error InvalidService();

    // Service custom errors
    error InvalidRegistry();
    error NotRegistry();
    error ToBeDetermined();
}
