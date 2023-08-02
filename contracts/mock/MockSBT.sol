// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockSBT is ERC721("Mock SBT", "MSBT") {
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        require(to == address(0) || from == address(0), "cannot transfer after minted");
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
