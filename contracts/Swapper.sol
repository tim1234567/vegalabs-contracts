//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../node_modules/prb-math/contracts/PRBMathUD60x18.sol";

contract Swapper is Ownable {

    using PRBMathUD60x18 for uint256;

    AggregatorV3Interface public priceFeed;


    IERC20 public usdt;

    IERC20 public wbtc;

    uint8 slippage;

    constructor(
        address _priceFeed,
        address _usdt,
        address _wbtc
    )  {
        priceFeed = AggregatorV3Interface(_priceFeed);
        usdt = IERC20(_usdt);
        wbtc = IERC20(_wbtc);
    }
    using Counters for Counters.Counter;
    Counters.Counter private _counter;

    function swap(uint256 _amount) public returns (uint256, uint8) { 
        IERC20(usdt).transferFrom(msg.sender, address(this), _amount);
        require(_amount < IERC20(usdt).balanceOf(address(this)), "!balance swapper low");
        _counter.increment();
        slippage = 1;
        if (_counter.current() % 2 == 0) { 
            slippage = 2;
        }
        (,int currentPrice,,,) = priceFeed.latestRoundData();
        uint256 quantityToGet = _amount.div(uint256(currentPrice));
        uint256 btcQuantity;
        if (slippage == 1) {
            btcQuantity = quantityToGet / 10e7;
        } else {
            btcQuantity = (quantityToGet - quantityToGet/slippage) / 10e7;
        }
        // IERC20(wbtc).transfer(address(msg.sender));
        return (btcQuantity, slippage);
    }

}