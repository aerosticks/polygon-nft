// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

import "contracts/Shared.sol";
import "contracts/Generate.sol";
import "contracts/Attack.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;

    using SharedStructs for SharedStructs.Character;
    using SharedStructs for mapping(uint256 => SharedStructs.Character);

    mapping(uint256 => SharedStructs.Character) public characterStats;

    Counters.Counter private _tokenIds;

    event Minted(address indexed owner, uint256 indexed tokenId);
    event Trained(uint256 indexed tokenId, uint256 newLevel, uint256 remainingXP);
    event Attacked(
        uint256 indexed attackerTokenId, uint256 indexed victimTokenId, uint256 attackDamage, uint256 defenseDamage
    );
    event Burned(uint256 indexed tokenId);
    event XPgained(address indexed owner, uint256 xpPoints);
    event Killed(address indexed owner, uint256 indexed tokenId);
    event Revived(uint256 indexed tokenId);
    event Healed(uint256 indexed tokenId, uint256 healAmount);

    uint256 constant RANDOM_STATS = 100;
    uint256 constant BASE_XP_LEVEL = 50;
    uint256 constant REVIVE_COST = 100;
    uint256 constant HEAL_COST = 65;

    mapping(address => uint256) public experiencePoints;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function getXP(address _user)
        public
        view
        returns (uint256 xpAmount, uint256 healNeededAmount, uint256 reviveNeededAmount)
    {
        xpAmount = experiencePoints[_user];
        healNeededAmount = HEAL_COST;
        reviveNeededAmount = REVIVE_COST;
    }

    function getAmountForNextLevel(uint256 tokenId) public view returns (uint256) {
        uint256 xpAmountToLevelUp = (characterStats[tokenId].level * BASE_XP_LEVEL) + BASE_XP_LEVEL;

        return xpAmountToLevelUp;
    }

    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = characterStats[tokenId].level;
        return levels.toString();
    }

    function getCharacterStats(uint256 tokenId) public view returns (SharedStructs.Character memory) {
        SharedStructs.Character memory char = characterStats[tokenId];
        return char;
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        SharedStructs.Character memory characterForToken = characterStats[newItemId];
        _setTokenURI(newItemId, GenerateLogic.getTokenURI(characterForToken, newItemId, msg.sender));
        emit Minted(msg.sender, newItemId);
    }

    function existAndOwner(uint256 tokenId) internal {
        require(_exists(tokenId), "Please use an existing token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to train it");
    }

    function train(uint256 tokenId) public {
        existAndOwner(tokenId);
        require(characterStats[tokenId].alive == true, "Needs to be alive to train!");
        require(
            (characterStats[tokenId].level * BASE_XP_LEVEL) + BASE_XP_LEVEL <= experiencePoints[msg.sender],
            "Don't have enough XP to train next level!"
        );
        uint256 currentLevel = characterStats[tokenId].level;
        uint256 currentXP = experiencePoints[msg.sender];
        uint256 xpAmountToLevelUp = (characterStats[tokenId].level * BASE_XP_LEVEL) + BASE_XP_LEVEL;

        experiencePoints[msg.sender] = currentXP - xpAmountToLevelUp;
        characterStats[tokenId].level = currentLevel + 1;
        SharedStructs.Character memory characterForToken = characterStats[tokenId];

        _setTokenURI(tokenId, GenerateLogic.getTokenURI(characterForToken, tokenId, msg.sender));
        emit Trained(tokenId, characterStats[tokenId].level, experiencePoints[msg.sender]);
    }

    function attack(uint256 tokenId1, uint256 tokenId2) public {
        require(_exists(tokenId1), "Please use an existing token #1");
        require(_exists(tokenId2), "Please use an existing token #2");
        existAndOwner(tokenId1);
        existAndOwner(tokenId2);

        SharedStructs.Character memory char1 = characterStats[tokenId1];
        SharedStructs.Character memory char2 = characterStats[tokenId2];

        (uint256 attackValue, uint256 defenseValue) = ActionLogic.attack(char1, char2, experiencePoints);

        _setTokenURI(char1.id, GenerateLogic.getTokenURI(char1, char1.id, msg.sender));
        _setTokenURI(char2.id, GenerateLogic.getTokenURI(char2, char2.id, msg.sender));
        emit Attacked(char1.id, char2.id, attackValue, defenseValue);

        emit XPgained(msg.sender, experiencePoints[msg.sender]);
    }

    function revive(uint256 tokenId) public {
        existAndOwner(tokenId);
        require(characterStats[tokenId].alive == false, "Token already alive.");
        require(experiencePoints[msg.sender] >= REVIVE_COST, "Don't have enough XP to revive.");

        uint256 currentXP = experiencePoints[msg.sender];
        experiencePoints[msg.sender] = currentXP - REVIVE_COST;

        characterStats[tokenId].life = 100;
        characterStats[tokenId].alive = true;

        SharedStructs.Character memory characterForToken = characterStats[tokenId];

        _setTokenURI(tokenId, GenerateLogic.getTokenURI(characterForToken, tokenId, msg.sender));
        emit Revived(tokenId);
    }

    function heal(uint256 tokenId) public {
        existAndOwner(tokenId);
        require(characterStats[tokenId].alive == true, "Token needs to be alive!");
        require(characterStats[tokenId].life < 100, "Token already at full health.");
        require(experiencePoints[msg.sender] >= HEAL_COST, "Don't have enough XP to heal.");

        uint256 currentLife = characterStats[tokenId].life;
        uint256 currentXP = experiencePoints[msg.sender];
        experiencePoints[msg.sender] = currentXP - HEAL_COST;

        characterStats[tokenId].life = 100;

        uint256 healedFor = 100 - currentLife;

        SharedStructs.Character memory characterForToken = characterStats[tokenId];

        _setTokenURI(tokenId, GenerateLogic.getTokenURI(characterForToken, tokenId, msg.sender));
        emit Healed(tokenId, healedFor);
    }
}
