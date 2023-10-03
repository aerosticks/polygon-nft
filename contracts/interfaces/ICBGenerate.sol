// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "contracts/Shared.sol";

interface ICBGenerate {
    function getTokenURI(SharedStructs.Character memory char, uint256 tokenid, address owner) external;
}
