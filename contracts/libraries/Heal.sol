// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "contracts/Shared.sol";

library HealLogic {
    uint256 constant HEAL_COST = 65;

    function heal(SharedStructs.Character memory characterStats, mapping(address => uint256) storage experiencePoints)
        internal
        returns (uint256 healedFor)
    {
        require(characterStats.alive == true, "Token needs to be alive!");
        require(characterStats.life < 100, "Token already at full health.");
        require(experiencePoints[msg.sender] >= HEAL_COST, "Don't have enough XP to heal.");

        uint256 currentLife = characterStats.life;
        uint256 currentXP = experiencePoints[msg.sender];
        experiencePoints[msg.sender] = currentXP - HEAL_COST;

        characterStats.life = 100;

        healedFor = 100 - currentLife;
    }
}
