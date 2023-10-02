// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "contracts/Shared.sol";

interface ICBTrain {
    function train(SharedStructs.Character memory char, uint256 currentXP) external;
}
