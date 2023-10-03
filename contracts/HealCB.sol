// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "contracts/Shared.sol";
import "contracts/interfaces/IChainBattles.sol";
import "contracts/interfaces/ICBHeal.sol";

contract CBHeal is ICBHeal {
    IChainBattles public chainBattleContract;

    uint256 constant HEAL_COST = 65;

    event Healed(uint256 indexed tokenId, uint256 healAmount);

    constructor(address _chainBattleContract) {
        chainBattleContract = IChainBattles(_chainBattleContract);
    }

    function heal(SharedStructs.Character memory char, uint256 currentXP) external {
        chainBattleContract.verifyOwnerAndToken(char.id);
        require(char.alive == true, "Token needs to be alive!");
        require(char.life < 100, "Token already at full health.");
        require(currentXP >= HEAL_COST, "Don't have enough XP to heal.");

        chainBattleContract.updateExperiencePoints(char.owner, HEAL_COST, false);

        uint256 healedFor = 100 - char.life;
        char.life = 100;

        emit Healed(char.id, healedFor);
    }
}
