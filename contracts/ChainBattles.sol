// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// The ERC721URIStorage contract that will be used as a foundation of our ERC721 Smart contract
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// The counters.sol library, will take care of handling and storing our tokenIDs
import "@openzeppelin/contracts/utils/Counters.sol";
// The string.sol library to implement the "toString()" function, that converts data into strings - sequences of characters
import "@openzeppelin/contracts/utils/Strings.sol";
// The Base64 library that, as we've seen previous, will help us handle base64 data like our on-chain SVGs
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

    mapping(uint256 => uint256) public tokenIdToLevels;

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
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
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
        tokenIdToLevels[newItemId] = 0;
        _setTokenURI(newItemId, getTokenURI(newItemId, msg.sender));
        emit Minted(msg.sender, newItemId);
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to train it");
        require(
            (characterStats[tokenId].level * BASE_XP_LEVEL) + BASE_XP_LEVEL <= experiencePoints[msg.sender],
            "Don't have enough XP to train next level!"
        );

        // uint256 currentLevel = tokenIdToLevels[tokenId];
        // tokenIdToLevels[tokenId] = currentLevel + 1;
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

    function attack(uint256 tokenId1, uint256 tokenId2) public {
        require(_exists(tokenId1), "Please use an existing token #1");
        require(_exists(tokenId2), "Please use an existing token #2");
        require(ownerOf(tokenId1) == msg.sender, "You must own token #1");

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
        uint256 currentOpponentLife = characterStats[tokenId2].life;
        uint256 currentOpponentLevel = characterStats[tokenId2].level;
        uint256 currentXP = experiencePoints[msg.sender];
        uint256 currentTokenLife = characterStats[tokenId1].life;
        uint256 currentTokenLevel = characterStats[tokenId1].level;

        if (attackValue > currentOpponentLife) {
            if (currentOpponentLevel == 0) {
                // Burn the token if its level is 0
                _burn(tokenId2); // _burn is a function provided by the ERC721 contract to destroy a token
                emit Burned(tokenId2);
            } else {
                // Decrease the level by 1 and adjust the life
                characterStats[tokenId2].level = currentOpponentLevel - 1;
                characterStats[tokenId2].life = 100 + currentOpponentLife - attackValue;
            }
        } else {
            // Reduce the life of the character by the attackValue
            characterStats[tokenId2].life = currentOpponentLife - attackValue;
        }

        if (defenseValue > currentTokenLife) {
            if (currentTokenLevel == 0) {
                // Burn the token if its level is 0
                _burn(tokenId1); // _burn is a function provided by the ERC721 contract to destroy a token
                emit Burned(tokenId1);
            } else {
                // Decrease the level by 1 and adjust the life
                characterStats[tokenId1].level = currentTokenLevel - 1;
                characterStats[tokenId1].life = 100 + currentTokenLife - defenseValue;
            }
        } else {
            // Reduce the life of the character by the attackValue
            characterStats[tokenId1].life = currentTokenLife - defenseValue;
        }

        _setTokenURI(tokenId1, getTokenURI(tokenId1, msg.sender));
        _setTokenURI(tokenId2, getTokenURI(tokenId2, msg.sender));
        emit Attacked(tokenId1, tokenId2, attackValue, defenseValue);

        experiencePoints[msg.sender] = currentXP + attackValue;
        emit XPgained(msg.sender, experiencePoints[msg.sender]);
    }

    function getAttackValue(uint256 maxDamage) internal view returns (uint256) {
        uint256 attackNum = random(maxDamage);
        return attackNum;
    }
}
