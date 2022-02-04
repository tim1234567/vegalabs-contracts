//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
ERC20 wrapper used for testing. Any account can call mint()
*/

contract MockUSD is ERC20 {
    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {}

    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}