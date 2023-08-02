# Basic Attestations Registry

## Architecture

#### 1. Registry

Implemented in `AttestRegistry.sol`, only contract owner can register service contracts for each different attestation form types (e.g. Verifiable Credentials, SoulBound Token, IPFS-url, Onchain bytes, ...)

You can get service contract address per each type.

Attest or Revoke function calls should be done via this registry contract as well, it will internally call related service's attest or revoke function.

#### 2. Services

More services can be added by inheriting `BaseAttestService.sol`, but you need to add more enums to AttestType in `IAttestService.sol`.
BaseAttestService contains `onAttest`, `onRevoke` virtual functions and you need to override that in the children contracts and implement necessary features.
For example, in VC, IPFS, OB Attest Service contracts just reverts with `ToBeDetermined` error, but SBT contract tries to log SBT contract address in `onAttest` function.

And for each service, also contract owners can update registry address.

## How to build the app

- install dependencies

  `npm run install`

- compile smart contracts

  `npm run compile`

- run tests

  `npm run test`

- check coverage of tests

  `npm run coverage`
