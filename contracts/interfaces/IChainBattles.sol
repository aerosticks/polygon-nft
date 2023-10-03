// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "contracts/Shared.sol";

interface IChainBattles {
    function updateExperiencePoints(address player, uint256 amount, bool add) external;
    function setNewToken(uint256 tokenId, SharedStructs.Character memory characterStats, address owner) external;
    function mintNewToken(address owner, uint256 newId) external returns (SharedStructs.Character memory);
    function verifyOwnerAndToken(uint256 tokenId) external;
    function initializeCharacter(uint256 tokenId, SharedStructs.Character memory) external;
}
