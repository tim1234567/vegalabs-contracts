// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "../node_modules/prb-math/contracts/PRBMathUD60x18.sol";

contract Vegalabs is Ownable {

    using PRBMathUD60x18 for uint256;
    AggregatorV3Interface public priceFeed;

    constructor(
        address _priceFeed
    ) {
        // get price feed
        priceFeed = AggregatorV3Interface(_priceFeed);

    }

    function getTotalAssetUSD(
        uint256 _oldUSDAmount,
        uint256 _newUSDAmount,
        uint256 _userCollateral
    ) pure public returns(uint256) {
        return (_oldUSDAmount - _newUSDAmount) + _userCollateral;
    }

    function getTotalAssetBTC(
        uint256 _newBTCAmount,
        uint256 _oldBTCAmount
    ) pure public returns(uint256) {
        return _newBTCAmount - _oldBTCAmount;
    }

    function getTargetBTC(
        uint256 _spentUSDT,
        uint256 _price
    ) pure public returns(uint256) {
        return _spentUSDT.div(_price);
    }

    function getSlippage(
        uint256 _realBTC,
        uint256 _targetBTC
    ) pure public returns(uint256) {
        // uint256 _gainBTC = getTotalAssetBTC(_newBTCAmount, _oldBTCAmount);
        // uint256 _spentUSDT = getTotalAssetUSD(_oldUSDAmount, _newUSDAmount, _userCollateral);
        uint256 slippage = 1 * 10e7 - (_realBTC.div(_targetBTC)).mul(10e7);
        return slippage;
    }

    function verify(
        uint256 _newBTCAmount, 
        uint256 _oldBTCAmount, 
        uint256 _newUSDAmount, 
        uint256 _oldUSDAmount,
        uint256 _userCollateral,
        uint8 leverage
        //leverage
    ) external view returns (bool) {
        (,int price,,,) = priceFeed.latestRoundData();

        require(_newBTCAmount > _oldBTCAmount, "!errorBalance");
        require(_newUSDAmount < _oldUSDAmount, "!errorBalance");
        uint256 _gainBTC = getTotalAssetBTC(_newBTCAmount, _oldBTCAmount);
        uint256 _spentUSDT = getTotalAssetUSD(_oldUSDAmount, _newUSDAmount, _userCollateral);
        // fetch price for btc
        
        require(_spentUSDT > 0, "!spent error in amount , spent <= 0");
        
        uint256 targetBTC = getTargetBTC(_spentUSDT, uint256(price));
        require(targetBTC > 0, "!fixed-point error");

        uint256 gain = uint256(_gainBTC);
        uint256 target = uint256(targetBTC);
        // uint256 slippage = 1 - uint256(_gainBTC / targetBTC);
        // uint256 slippage = 1 - gain.div(target);
        uint256 slippage = getSlippage(gain, target);
        uint256 equity = 1 / leverage;
        // require(slippage < equity , "!error");
        // if (_gainBTC >= targetBTC) {
        //     return true;
        // }

        if (slippage < equity) {
            return true;
        }        

        return false;
    }

}