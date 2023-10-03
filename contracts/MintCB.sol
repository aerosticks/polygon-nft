// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";

import "contracts/interfaces/IChainBattles.sol";
import "contracts/interfaces/ICBMint.sol";

contract CBMint is ICBMint {
    IChainBattles public chainBattlesContract;

    using Counters for Counters.Counter;

    event Minted(address indexed owner, uint256 indexed tokenId);

    constructor(address _chainBattlesContract) {
        chainBattlesContract = IChainBattles(_chainBattlesContract);
    }

    Counters.Counter private _tokenIds;

    function mint(address _owner) external override {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        SharedStructs.Character memory char = chainBattlesContract.mintNewToken(_owner, newItemId);

        chainBattlesContract.initializeCharacter(newItemId, char);

        chainBattlesContract.setNewToken(newItemId, char, _owner);

        emit Minted(_owner, newItemId);
    }
}
