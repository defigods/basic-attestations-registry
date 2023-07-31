// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IRegistry {
    event AttestRegistered(
        uint256 id,
        address indexed attester,
        address indexed attestee,
        AttestType indexed aType,
        bytes key,
        bytes value
    );

    enum AttestType {
        VC, //   verifiable credentials
        SBT, //  soulbound token
        IPFS, // ipfs-url
        OB //    on-chain bytes
    }

    struct Attest {
        AttestType aType; // attest form types
        address attester; // address who attests
        address attestee; // address who get attests
        /**
          switch (aType)
            VC   => key of metadata
            SBT  => nft address
            IPFS => ipfs url
            OB   => bytes data
         */
        bytes key;
        /**
          switch (aType)
            VC   => value for key of metadata
            SBT  => tokenId
            IPFS => n/a
            OB   => n/a
         */
        bytes value;
    }

    function attest(
        AttestType _type,
        address _attestee,
        bytes memory _key,
        bytes memory _value
    ) external;
}
