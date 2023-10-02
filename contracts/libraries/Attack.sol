// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "contracts/libraries/Generate.sol";
import "contracts/Shared.sol";

library ActionLogic {
    event Killed(address indexed owner, uint256 indexed tokenId);
    event Attacked(
        uint256 indexed attackerTokenId, uint256 indexed victimTokenId, uint256 attackDamage, uint256 defenseDamage
    );
    event XPgained(address indexed owner, uint256 xpPoints);

    function getAttackPotential(SharedStructs.Character memory characterStats) internal view returns (uint256) {
        uint256 strength = characterStats.strength;
        uint256 speed = characterStats.speed;
        uint256 level = characterStats.level;

        if (strength == 0 || speed == 0) {
            return 10;
        }

        return (strength * (level + 1) * 10) / speed;
    }

    function updateToken(SharedStructs.Character memory characterStats, uint256 attackValue) internal {
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
    ) internal {
        uint256 attackValue = getAttackValue(getAttackPotential(characterStats1));
        uint256 defenseValue = getAttackValue(getAttackPotential(characterStats2));

        uint256 currentXP = experiencePoints[characterStats1.owner];
        uint256 enemyCurrentXP = experiencePoints[characterStats2.owner];

        updateToken(characterStats2, attackValue);
        updateToken(characterStats1, defenseValue);

        experiencePoints[characterStats1.owner] = currentXP + attackValue;
        experiencePoints[characterStats2.owner] = enemyCurrentXP + defenseValue;

        emit Attacked(characterStats1.id, characterStats2.id, attackValue, defenseValue);
        emit XPgained(msg.sender, experiencePoints[msg.sender]);
    }

    function getAttackValue(uint256 maxDamage) internal view returns (uint256) {
        uint256 attackNum = GenerateLogic.random(maxDamage);
        return attackNum;
    }
}
