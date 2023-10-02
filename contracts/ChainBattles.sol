// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "contracts/Shared.sol";

import "contracts/AttackCB.sol";
import "contracts/MintCB.sol";
import "contracts/ReviveCB.sol";
import "contracts/TrainCB.sol";
import "contracts/HealCB.sol";

import "contracts/libraries/Generate.sol";

import "contracts/interfaces/IChainBattles.sol";

contract ChainBattles is ERC721URIStorage, IChainBattles, Ownable {
    ICBAttack public attackModule;
    ICBMint public mintModule;
    ICBRevive public reviveModule;
    ICBTrain public trainModule;
    ICBHeal public healModule;

    using SharedStructs for SharedStructs.Character;
    using SharedStructs for mapping(uint256 => SharedStructs.Character);

    mapping(uint256 => SharedStructs.Character) public characterStats;

    // event Burned(uint256 indexed tokenId);
    // event Killed(address indexed owner, uint256 indexed tokenId);

    event XPgained(address indexed owner, uint256 xpPoints);

    uint256 constant BASE_XP_LEVEL = 50;
    uint256 constant REVIVE_COST = 100;
    uint256 constant HEAL_COST = 65;

    mapping(address => uint256) public experiencePoints;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function setModules(
        address _attackModule,
        address _mintModule,
        address _reviveModule,
        address _trainModule,
        address _healModule
    ) external onlyOwner {
        attackModule = ICBAttack(_attackModule);
        mintModule = ICBMint(_mintModule);
        reviveModule = ICBRevive(_reviveModule);
        trainModule = ICBTrain(_trainModule);
        healModule = ICBHeal(_healModule);
    }

    function getCharStats(uint256 tokenId) internal view returns (SharedStructs.Character memory) {
        SharedStructs.Character memory char = characterStats[tokenId];
        return char;
    }

    function getXP(uint256 tokenId)
        public
        view
        returns (uint256 xpAmount, uint256 healNeededAmount, uint256 reviveNeededAmount, uint256 nextLevelXp)
    {
        xpAmount = experiencePoints[msg.sender];
        healNeededAmount = HEAL_COST;
        reviveNeededAmount = REVIVE_COST;
        nextLevelXp = (getCharStats(tokenId).level * BASE_XP_LEVEL) + BASE_XP_LEVEL;
        return (xpAmount, healNeededAmount, reviveNeededAmount, nextLevelXp);
    }

    function getCharacterStats(uint256 tokenId) public view returns (SharedStructs.Character memory) {
        return getCharStats(tokenId);
    }

    function mint() public {
        mintModule.mint(msg.sender);
    }

    function verifyOwnerAndToken(uint256 tokenId) external {
        require(_exists(tokenId), "Token n/a");
        require(ownerOf(tokenId) == msg.sender, "Not Owner");
    }

    function mintNewToken(address owner, uint256 newId) external returns (SharedStructs.Character memory) {
        _safeMint(owner, newId);
        return getCharStats(newId);
    }

    function updateExperiencePoints(address player, uint256 amount, bool add) external override {
        // require(msg.sender == address(attackModule), "Only the attack module can call this function");

        if (add == true) {
            experiencePoints[player] += amount;
        } else {
            experiencePoints[player] -= amount;
        }
    }

    function setNewToken(uint256 tokenId, SharedStructs.Character memory charStats, address owner) external override {
        _setTokenURI(tokenId, GenerateLogic.getTokenURI(charStats, tokenId, owner));
    }

    function train(uint256 tokenId) public {
        trainModule.train(getCharStats(tokenId), experiencePoints[getCharStats(tokenId).owner]);
    }

    function attack(uint256 tokenId1, uint256 tokenId2) public {
        attackModule.attack(getCharStats(tokenId1), getCharStats(tokenId2));

        emit XPgained(msg.sender, experiencePoints[msg.sender]);
    }

    function revive(uint256 tokenId) public {
        reviveModule.revive(getCharStats(tokenId), experiencePoints[getCharStats(tokenId).owner]);
    }

    function heal(uint256 tokenId) public {
        healModule.heal(getCharStats(tokenId), experiencePoints[getCharStats(tokenId).owner]);
    }
}
