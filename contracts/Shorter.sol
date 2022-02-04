//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


import "../interfaces/ISwapper.sol";

import "../interfaces/IVegalabs.sol";

contract Shorter is Ownable {

    SwapInterface public swapper;

    IVegalabs public vegalabs;

    AggregatorV3Interface public priceFeed;


    uint8 count;

    IERC20 public usdt;

    IERC20 public wbtc;

    mapping(address => uint256) balanceUSD;
    mapping(address => uint256) balanceBTC;



    event SetSwapper(address _newSwapper);
    event ShortState(uint256 amount, uint8 leverage, bool verified);
    event Shorted(uint256 _oldAmount, uint256 newAmount);
    event StateVerify(
        uint256 newAmountBTC,
        uint256 oldAmountBTC, 
        uint256 newAmountUSD,
        uint256 oldAmountUSD,
        uint8 leverage
    );
    event LeverageAmount(
        uint256 amountProvided,
        uint256 amountLeverage
    );
    constructor(
        address _swapper,
        address _vegalabs,
        address _priceFeed,
        address _usdt,
        address _wbtc
    ) {
        swapper = SwapInterface(_swapper);
        vegalabs = IVegalabs(_vegalabs);
        priceFeed = AggregatorV3Interface(_priceFeed);
        usdt = IERC20(_usdt);
        wbtc = IERC20(_wbtc);
    }
    // uint256 currentPriceFromChainlink = 0;

    function setSwapper(address newSwapper) public onlyOwner {
        swapper = SwapInterface(newSwapper);
        emit SetSwapper(newSwapper);
    }


    function addUSD(uint256 amount) external {
        IERC20(usdt).transferFrom(msg.sender, address(this), amount);
        balanceUSD[msg.sender] += amount;
    }


    // refractor short
    function short(uint256 amountUSD, uint8 leverage) external {
        uint256 oldAmountUSD = IERC20(usdt).balanceOf(address(this));
        uint256 oldAmountBTC = balanceBTC[msg.sender];
        uint256 newAmountUSD = oldAmountUSD - amountUSD;
        uint256 trueAmount = amountUSD * leverage;
        IERC20(usdt).approve(address(swapper), 2**256 -1);
        (uint256 btcquantity, ) = swapper.swap(trueAmount);
        uint256 newAmountBTC = oldAmountBTC + btcquantity; 
        emit StateVerify(newAmountBTC, oldAmountBTC, newAmountUSD, oldAmountUSD, leverage);
        emit LeverageAmount(amountUSD, trueAmount);
        bool verified = vegalabs.verify(newAmountBTC, oldAmountBTC, newAmountUSD, oldAmountUSD, amountUSD, leverage);
        require(verified == true, "!slippage");
        balanceUSD[msg.sender] = newAmountUSD;
        balanceBTC[msg.sender] += btcquantity;
        count++;
        emit ShortState(amountUSD, leverage, verified);
    }


    function retrieve() public view returns (int) {
        (,int currentPrice,,,) = priceFeed.latestRoundData();
        return currentPrice;
    }

}