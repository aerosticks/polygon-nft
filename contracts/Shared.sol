// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SharedStructs {
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
}
