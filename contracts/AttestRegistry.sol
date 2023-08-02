// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {IAttestService, AttestType, Attest} from "./interfaces/IAttestService.sol";
import {Errors} from "./libraries/Errors.sol";

contract AttestRegistry is Ownable {
    using Address for address;

    event AttestServiceRegistered(AttestType indexed _type, address _registerer, address _service);

    mapping(AttestType => address) private _attests;

    function register(
        AttestType _type,
        address _service,
        bool _forceUpdate
    ) external onlyOwner {
        if (!_service.isContract()) revert Errors.InvalidService();
        if (_attests[_type] != address(0) && !_forceUpdate) revert Errors.ServiceAlreadyExists();
        _attests[_type] = _service;
        emit AttestServiceRegistered(_type, msg.sender, _service);
    }

    function attest(AttestType _type, Attest calldata _attest) external returns (bool) {
        address service = _attests[_type];
        if (service == address(0)) revert Errors.ServiceNotExists();
        return IAttestService(service).attest(_attest);
    }

    function revoke(AttestType _type, Attest calldata _attest) external returns (bool) {
        address service = _attests[_type];
        if (service == address(0)) revert Errors.ServiceNotExists();
        return IAttestService(service).revoke(_attest);
    }

    function getAttestService(AttestType _type) external view returns (address) {
        return _attests[_type];
    }
}
