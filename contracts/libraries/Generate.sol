// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "contracts/Shared.sol";

library GenerateLogic {
    using Strings for uint256;

    uint256 constant RANDOM_CLASS = 5;

    function generateCharacter(SharedStructs.Character memory characterStats) internal pure returns (string memory) {
        string memory fontColor;
        string memory bgColor;

        if (characterStats.alive) {
            fontColor = "white";
            bgColor = "black";
        } else {
            fontColor = "black";
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
            characterStats.id.toString(),
            "</text>",
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Class: ",
            characterStats.class,
            "</text>",
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Level: ",
            characterStats.level.toString(),
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Speed: ",
            characterStats.speed.toString(),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Strength: ",
            characterStats.strength.toString(),
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Life: ",
            characterStats.life.toString(),
            "</text>",
            "</svg>"
        );

        return string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(svg)));
    }

    function getTokenURI(SharedStructs.Character memory characterStats, uint256 tokenId, address _owner)
        internal
        view
        returns (string memory)
    {
        if (((characterStats.initialized == false))) {
            uint256[2] memory randArray = randomArray([uint256(85), uint256(80)]);
            uint256 level = 0;
            string memory charClass = getCharClass(random(RANDOM_CLASS));
            uint256 speed = randArray[0];
            uint256 strength = randArray[1];
            uint256 life = 100;

            characterStats =
                SharedStructs.Character(tokenId, level, speed, strength, life, charClass, _owner, true, true);

            // return characterStats;
        }

        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(characterStats),
            '"',
            "}"
        );
        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(dataURI)));
    }

    function getCharClass(uint256 index) internal pure returns (string memory) {
        string[5] memory charClasses = ["Warrior", "Mage", "Healer", "Wizard", "Archer"];
        require(index < 5, "Index out of bounds");
        return charClasses[index];
    }

    function random(uint256 number) internal view returns (uint256) {
        if (number == 0) {
            return 0;
        } else {
            return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % number;
        }
    }

    function randomArray(uint256[2] memory _myArray) internal view returns (uint256[2] memory) {
        uint256[2] memory results;

        for (uint256 i = 0; i < _myArray.length; i++) {
            uint256 divisor = (_myArray[i] == 0) ? 1 : _myArray[i];
            results[i] = (uint256(keccak256(abi.encodePacked(block.timestamp, i))) % divisor);
        }

        return results;
    }
}
