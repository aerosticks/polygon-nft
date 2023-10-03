// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "contracts/Shared.sol";
import "contracts/interfaces/IChainBattles.sol";
import "contracts/interfaces/ICBTrain.sol";

contract CBTrain is ICBTrain {
    IChainBattles public chainBattleContract;

    uint256 constant BASE_XP_LEVEL = 50;

    event Trained(uint256 indexed tokenId, uint256 newLevel, uint256 remainingXP);

    constructor(address _chainBattleContract) {
        chainBattleContract = IChainBattles(_chainBattleContract);
    }

    function train(SharedStructs.Character memory char, uint256 currentXP) external {
        chainBattleContract.verifyOwnerAndToken(char.id);
        require(char.alive == true, "Needs to be alive to train!");
        require((char.level * BASE_XP_LEVEL) + BASE_XP_LEVEL <= currentXP, "Don't have enough XP to train next level!");

        uint256 currentLevel = char.level;
        uint256 xpAmountToLevelUp = (char.level * BASE_XP_LEVEL) + BASE_XP_LEVEL;

        chainBattleContract.updateExperiencePoints(char.owner, xpAmountToLevelUp, false);
        char.level = currentLevel + 1;

        chainBattleContract.setNewToken(char.id, char, char.owner);

        emit Trained(char.id, char.level, currentXP - xpAmountToLevelUp);
    }
}
