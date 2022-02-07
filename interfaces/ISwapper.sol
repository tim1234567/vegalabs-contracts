// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface SwapInterface {
   function swap(uint256 amount) external returns (uint256, uint8);
}