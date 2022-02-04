//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "@openzeppelin/contracts/utils/Strings.sol";



contract Shorter is Ownable {

    constructor() public {}

    mapping (address => uint256) public balanceUSD; 
    mapping (address => uint256) public balanceBTC; 

    address private swapper = 0x1B23bb2F88E043C5C358672A855b74d97331B741;
    uint256 currentPriceFromChainlink = 0;

    function enoughCollateral(uint256 gainedBTC, uint256 targetBTC, uint8 leverage) public returns (bool) {

        // TODO change uint to float 
        uint256 slippage = 1 - gainedBTC / targetBTC;
        uint256 equityShare = 1 / leverage;
        if (slippage < equityShare) {
            return true;
        }
        return false;
    }

    function verify(uint256 oldAmountUSD, uint256 newAmountUSD, uint256 oldAmountBTC, uint256 newAmountBTC, uint8 leverage ) public returns (bool) {
        uint256 spentUsd = oldAmountUSD - newAmountUSD;
        uint256 gainedBTC = newAmountBTC - oldAmountBTC;
        uint256 targetBTC = spentUsd / currentPriceFromChainlink;

        if (enoughCollateral(gainedBTC, targetBTC, leverage)) {
            return true;
        }
        return false;

        // Dont know what logic should be here 
        return false;
    }

    function setSwapper(address newSwapper) public onlyOwner {
        swapper = newSwapper;
    }

    function addUSD() public {
        balanceUSD[msg.sender] += 10000;
    }


    function short(uint256 amountUSD, uint8 leverage) public { 
        uint256 trueAmount = amountUSD*leverage;
        uint256 oldAmountUSD = balanceUSD[msg.sender];
        uint256 oldAmountBTC = balanceBTC[msg.sender];
        uint256 newAmountUSD = oldAmountUSD - amountUSD;
        SwapInterface swapper = SwapInterface(swapper);
        (uint256 amount, uint8 slippage) = swapper.swap(trueAmount);
        require(verify(oldAmountUSD, newAmountUSD, oldAmountBTC, amount, leverage));
        
        balanceBTC[msg.sender] += amount;
        balanceUSD[msg.sender] = newAmountUSD;
    }

}

abstract contract SwapInterface {
    function swap(uint256 amount) public virtual returns (uint256, uint8);
}