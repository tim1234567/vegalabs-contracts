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

    mapping (address => uint256) public balances; 
    address private swapper = 0x1B23bb2F88E043C5C358672A855b74d97331B741;

    function verify(uint256 oldAmount, uint256 amount) public returns (bool) {
        // Dont know what logic should be here 
        return false;
    }

    function setSwapper(address newSwapper) public onlyOwner {
        swapper = newSwapper;
    }



    function short(uint256 amount, uint8 leverage) public { 
        uint256 trueAmount = amount*leverage;
        uint256 oldAmount = balances[msg.sender];
        SwapInterface swapper = SwapInterface(swapper);
        (uint256 amount, uint8 slippage) = swapper.swap(trueAmount);
        require(verify(oldAmount, amount));
        balances[msg.sender] = amount;
    }

}

abstract contract SwapInterface {
    function swap(uint256 amount) public virtual returns (uint256, uint8);
}