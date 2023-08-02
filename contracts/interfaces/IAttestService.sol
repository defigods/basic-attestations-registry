// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

enum AttestType {
    VC, //   verifiable credentials
    SBT, //  soulbound token
    IPFS, // ipfs-url
    OB //    on-chain bytes
}

struct Attest {
    address recipient; // address who get attests
    /**
          switch (aType)
            VC   => key of metadata
            SBT  => nft address
            IPFS => n/a
            OB   => n/a
         */
    bytes key;
    /**
          switch (aType)
            VC   => value for key of metadata
            SBT  => tokenId
            IPFS => ipfs url
            OB   => bytes data
         */
    bytes value;
}

interface IAttestService {
    function attest(Attest calldata) external;

    function revoke(Attest calldata) external;
}
