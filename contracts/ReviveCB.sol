// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "contracts/Shared.sol";
import "contracts/interfaces/IChainBattles.sol";
import "contracts/interfaces/ICBRevive.sol";

contract CBRevive is ICBRevive {
    IChainBattles public chainBattlesContract;

    uint256 constant REVIVE_COST = 100;

    event Revived(uint256 indexed tokenId);

    constructor(address _chainBattleContract) {
        chainBattlesContract = IChainBattles(_chainBattleContract);
    }

    function revive(SharedStructs.Character memory char, uint256 currentXP) external {
        require(char.alive == false, "Token already alive.");
        require(currentXP >= REVIVE_COST, "Don't have enough XP to revive.");
        chainBattlesContract.verifyOwnerAndToken(char.id);

        chainBattlesContract.updateExperiencePoints(msg.sender, REVIVE_COST, false);

        char.life = 100;
        char.alive = true;

        chainBattlesContract.setNewToken(char.id, char, char.owner);

        emit Revived(char.id);
    }
}
