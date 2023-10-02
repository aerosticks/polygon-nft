// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "contracts/Shared.sol";

library ReviveLogic {
    uint256 constant REVIVE_COST = 100;

    function revive(SharedStructs.Character memory characterStats, mapping(address => uint256) storage experiencePoints)
        internal
    {
        require(characterStats.alive == false, "Token already alive.");
        require(experiencePoints[msg.sender] >= REVIVE_COST, "Don't have enough XP to revive.");

        uint256 currentXP = experiencePoints[msg.sender];
        experiencePoints[msg.sender] = currentXP - REVIVE_COST;

        characterStats.life = 100;
        characterStats.alive = true;
    }
}
