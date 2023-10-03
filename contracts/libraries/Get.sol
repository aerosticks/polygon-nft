// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "contracts/Shared.sol";

library GetLogic {
    uint256 constant BASE_XP_LEVEL = 50;
    uint256 constant REVIVE_COST = 100;
    uint256 constant HEAL_COST = 65;

    function getXP(mapping(address => uint256) storage experiencePoints, SharedStructs.Character memory characterStats)
        internal
        view
        returns (uint256 xpAmount, uint256 healNeededAmount, uint256 reviveNeededAmount, uint256 nextLevelXp)
    {
        xpAmount = experiencePoints[msg.sender];
        healNeededAmount = HEAL_COST;
        reviveNeededAmount = REVIVE_COST;
        nextLevelXp = (characterStats.level * BASE_XP_LEVEL) + BASE_XP_LEVEL;
    }
}
