// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {IRegistry} from "./interfaces/IRegistry.sol";
import {Errors} from "./libraries/Errors.sol";

contract AttestationRegistry is IRegistry {
    using Address for address;

    Attest[] private _attests;
    mapping(address => uint256[]) private _attesterIndexes;

    function attest(
        AttestType _type,
        address _attestee,
        bytes memory _key,
        bytes memory _value
    ) external override {
        if (msg.sender.isContract()) {
            revert Errors.InvalidAttester();
        }
        if (_attestee == address(0)) {
            revert Errors.InvalidAttestee();
        }
        _attesterIndexes[msg.sender].push(_attests.length);
        _attests.push(Attest(_type, msg.sender, _attestee, _key, _value));
        emit AttestRegistered(_attests.length, msg.sender, _attestee, _type, _key, _value);
    }

    function attestByIndex(uint256 index)
        external
        view
        returns (
            AttestType,
            address,
            address,
            bytes memory,
            bytes memory
        )
    {
        Attest memory info = _attests[index];
        return (info.aType, info.attester, info.attestee, info.key, info.value);
    }

    function attestByAttesterAndIndex(address attester, uint256 index)
        external
        view
        returns (
            AttestType,
            address,
            address,
            bytes memory,
            bytes memory
        )
    {
        Attest memory info = _attests[_attesterIndexes[attester][index]];
        return (info.aType, info.attester, info.attestee, info.key, info.value);
    }
}
