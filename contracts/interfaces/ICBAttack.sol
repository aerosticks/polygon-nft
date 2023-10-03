// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "contracts/Shared.sol";

interface ICBAttack {
    function attack(SharedStructs.Character memory char1, SharedStructs.Character memory char2) external;
}
