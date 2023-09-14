// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;

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

    struct Character {
        uint256 id;
        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life;
        string class;
        address owner;
        bool alive;
        bool initialized;
    }

    Character character;

    uint256 constant RANDOM_STATS = 100;
    uint256 constant RANDOM_CLASS = 5;
    uint256 constant BASE_XP_LEVEL = 50;
    uint256 constant REVIVE_COST = 100;
    uint256 constant HEAL_COST = 65;

    mapping(uint256 => Character) public characterStats;

    mapping(address => uint256) public experiencePoints;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function getXP(address _user) public view returns (uint256) {
        uint256 tempXp = experiencePoints[_user];

        return tempXp;
    }

    function getAmountForNextLevel(uint256 tokenId) public view returns (uint256) {
        uint256 currentLevel = characterStats[tokenId].level;

        uint256 xpAmountToLevelUp = (characterStats[tokenId].level * BASE_XP_LEVEL) + BASE_XP_LEVEL;

        return xpAmountToLevelUp;
    }

    function random(uint256 number) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % number + 1;
    }

    function randomArray(uint256[2] memory _myArray) internal view returns (uint256[2] memory) {
        uint256[2] memory results;

        for (uint256 i = 0; i < _myArray.length; i++) {
            results[i] = (uint256(keccak256(abi.encodePacked(block.timestamp, i))) % _myArray[i]) + 1;
        }

        return results;
    }

    function generateCharacter(uint256 tokenId) public returns (string memory) {
        // Define a variable to store the fill color
        string memory fontColor;
        string memory bgColor;

        // Check the character's life status and set the fill color accordingly
        if (characterStats[tokenId].alive) {
            fontColor = "white"; // Set the fill color to black if the character is alive
            bgColor = "black";
        } else {
            fontColor = "black"; // Set the fill color to red if the character is dead
            bgColor = "red";
        }

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: ",
            fontColor,
            "; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="',
            bgColor,
            '" />',
            '<text x="50%" y="20%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "ID #",
            characterStats[tokenId].id.toString(),
            "</text>",
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Class: ",
            characterStats[tokenId].class,
            "</text>",
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Level: ",
            characterStats[tokenId].level.toString(),
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Speed: ",
            characterStats[tokenId].speed.toString(),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Strength: ",
            characterStats[tokenId].strength.toString(),
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Life: ",
            characterStats[tokenId].life.toString(),
            "</text>",
            "</svg>"
        );

        return string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(svg)));
    }

    function getLevels(uint256 tokenId) public view returns (string memory) {
        uint256 levels = characterStats[tokenId].level;
        return levels.toString();
    }

    function getCharacterStats(uint256 tokenId) public view returns (Character memory) {
        Character memory char = characterStats[tokenId];
        return char;
    }

    function getCharClass(uint256 index) internal pure returns (string memory) {
        string[5] memory charClasses = ["Warrior", "Mage", "Healer", "Wizard", "Archer"];
        require(index < 5, "Index out of bounds");
        return charClasses[index];
    }

    function getTokenURI(uint256 tokenId, address _owner) public returns (string memory) {
        if (((characterStats[tokenId].initialized == false))) {
            uint256[2] memory randArray = randomArray([uint256(85), uint256(80)]);
            uint256 level = 0;
            string memory charClass = getCharClass(random(RANDOM_CLASS));
            uint256 speed = randArray[0];
            uint256 strength = randArray[1];
            uint256 life = 100;

            characterStats[tokenId] = Character(tokenId, level, speed, strength, life, charClass, _owner, true, true);
        }

        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, getTokenURI(newItemId, msg.sender));
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

        _setTokenURI(tokenId, getTokenURI(tokenId, msg.sender));
        emit Trained(tokenId, characterStats[tokenId].level, experiencePoints[msg.sender]);
    }

    function getAttackPotential(uint256 tokenId) internal view returns (uint256) {
        uint256 strength = characterStats[tokenId].strength;
        uint256 speed = characterStats[tokenId].speed;
        uint256 level = characterStats[tokenId].level;

        if (strength == 0 || level == 0) {
            return 15;
        }

        if (speed == 0) {
            return 15;
        }

        return (strength * level) / speed;
    }

    function updateToken(uint256 attackValue, uint256 tokenId) internal {
        if (attackValue > characterStats[tokenId].life) {
            if (characterStats[tokenId].level == 0) {
                // if level 0 and life <= 0; token is marked as dead.
                characterStats[tokenId].level = 0;
                characterStats[tokenId].life = 0;
                characterStats[tokenId].alive = false;
                emit Killed(msg.sender, characterStats[tokenId].id);
            } else {
                // Decrease the level by 1 and adjust the life
                characterStats[tokenId].level = characterStats[tokenId].level - 1;
                characterStats[tokenId].life = 100 + characterStats[tokenId].life - attackValue;
            }
        } else {
            // Reduce the life of the character by the attackValue
            characterStats[tokenId].life = characterStats[tokenId].life - attackValue;
        }
    }

    function attack(uint256 tokenId1, uint256 tokenId2) public {
        require(_exists(tokenId2), "Please use an existing token #2");
        existAndOwner(tokenId1);

        uint256 attackerDamagePotential = getAttackPotential(tokenId1);
        uint256 attackerDamagePotential2 = getAttackPotential(tokenId2);

        uint256[2] memory randArray = randomArray([uint256(attackerDamagePotential), uint256(attackerDamagePotential2)]);

        uint256 defenderDamagePotential;

        if (randArray[0] > randArray[1]) {
            defenderDamagePotential = randArray[0] - randArray[1];
        } else if (randArray[0] < randArray[1]) {
            defenderDamagePotential = randArray[1] - randArray[0];
        } else {
            defenderDamagePotential = randArray[1];
        }

        uint256 attackValue = getAttackValue(randArray[0]);
        uint256 defenseValue = getAttackValue(defenderDamagePotential);
        uint256 currentXP = experiencePoints[msg.sender];
        uint256 enemyCurrentXP = experiencePoints[characterStats[tokenId2].owner];

        updateToken(attackValue, tokenId2);
        updateToken(defenseValue, tokenId1);

        _setTokenURI(tokenId1, getTokenURI(tokenId1, msg.sender));
        _setTokenURI(tokenId2, getTokenURI(tokenId2, msg.sender));
        emit Attacked(tokenId1, tokenId2, attackValue, defenseValue);

        experiencePoints[msg.sender] = currentXP + attackValue;
        experiencePoints[characterStats[tokenId2].owner] = enemyCurrentXP + defenseValue;
        emit XPgained(msg.sender, experiencePoints[msg.sender]);
    }

    function getAttackValue(uint256 maxDamage) internal view returns (uint256) {
        uint256 attackNum = random(maxDamage);
        return attackNum;
    }

    function revive(uint256 tokenId) public {
        existAndOwner(tokenId);
        require(characterStats[tokenId].alive == false, "Token already alive.");
        require(experiencePoints[msg.sender] >= REVIVE_COST, "Don't have enough XP to revive.");

        uint256 currentXP = experiencePoints[msg.sender];
        experiencePoints[msg.sender] = currentXP - REVIVE_COST;

        characterStats[tokenId].life = 100;
        characterStats[tokenId].alive = true;

        _setTokenURI(tokenId, getTokenURI(tokenId, msg.sender));
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

        _setTokenURI(tokenId, getTokenURI(tokenId, msg.sender));
        emit Healed(tokenId, healedFor);
    }
}
