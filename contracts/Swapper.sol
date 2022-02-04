//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Swapper is Ownable {
    constructor() public {}
    using Counters for Counters.Counter;
    Counters.Counter private _counter;
    uint currentPriceFromChainlink = 10;


    function swap(uint256 amount) public returns (uint256, uint8) { 
        _counter.increment();
        uint8 slippage = 1;
        if (_counter.current() % 2 == 0) { 
            slippage = 2;
        } 
        uint256 btcQuantity = currentPriceFromChainlink - currentPriceFromChainlink / slippage;
        return (btcQuantity, slippage);
    }

}