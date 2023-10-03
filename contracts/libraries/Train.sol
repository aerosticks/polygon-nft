// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "contracts/Shared.sol";

library TrainLogic {
    uint256 constant BASE_XP_LEVEL = 50;

    function train(SharedStructs.Character memory characterStats, mapping(address => uint256) storage experiencePoints)
        internal
    {
        require(characterStats.alive == true, "Needs to be alive to train!");
        require(
            (characterStats.level * BASE_XP_LEVEL) + BASE_XP_LEVEL <= experiencePoints[msg.sender],
            "Don't have enough XP to train next level!"
        );
        uint256 currentLevel = characterStats.level;
        uint256 currentXP = experiencePoints[msg.sender];
        uint256 xpAmountToLevelUp = (characterStats.level * BASE_XP_LEVEL) + BASE_XP_LEVEL;

        experiencePoints[msg.sender] = currentXP - xpAmountToLevelUp;
        characterStats.level = currentLevel + 1;
    }
}
