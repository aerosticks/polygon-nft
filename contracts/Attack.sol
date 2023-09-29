// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "contracts/Generate.sol";
import "contracts/Shared.sol";

library ActionLogic {
    event Killed(address indexed owner, uint256 indexed tokenId);

    function getAttackPotential(SharedStructs.Character memory characterStats, uint256 tokenId)
        internal
        view
        returns (uint256)
    {
        uint256 strength = characterStats.strength;
        uint256 speed = characterStats.speed;
        uint256 level = characterStats.level;

        if (strength == 0 || speed == 0) {
            return 10;
        }

        return (strength * (level + 1) * 10) / speed;
    }

    function updateToken(SharedStructs.Character memory characterStats, uint256 attackValue, uint256 tokenId)
        internal
    {
        if (attackValue >= characterStats.life) {
            if (characterStats.level == 0) {
                characterStats.level = 0;
                characterStats.life = 0;
                characterStats.alive = false;
                emit Killed(msg.sender, characterStats.id);
            } else {
                characterStats.level = characterStats.level - 1;
                characterStats.life = 100 + characterStats.life - attackValue;
            }
        } else {
            characterStats.life = characterStats.life - attackValue;
        }
    }

    function attack(
        SharedStructs.Character memory characterStats1,
        SharedStructs.Character memory characterStats2,
        mapping(address => uint256) storage experiencePoints
    ) internal returns (uint256, uint256) {
        uint256 attackValue = getAttackValue(getAttackPotential(characterStats1, characterStats1.id));
        uint256 defenseValue = getAttackValue(getAttackPotential(characterStats2, characterStats2.id));

        uint256 currentXP = experiencePoints[characterStats1.owner];
        uint256 enemyCurrentXP = experiencePoints[characterStats2.owner];

        updateToken(characterStats2, attackValue, characterStats2.id);
        updateToken(characterStats1, defenseValue, characterStats1.id);

        experiencePoints[characterStats1.owner] = currentXP + attackValue;
        experiencePoints[characterStats2.owner] = enemyCurrentXP + defenseValue;

        return (attackValue, defenseValue);
    }

    function getAttackValue(uint256 maxDamage) internal view returns (uint256) {
        uint256 attackNum = GenerateLogic.random(maxDamage);
        return attackNum;
    }
}
