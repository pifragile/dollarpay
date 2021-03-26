// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.3;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract GasPriceFeedMock is AggregatorV3Interface {
    function decimals() external view override returns (uint8){
        return 0;
    }

    function description() external view override returns (string memory){
        return "Mock Description";
    }

    function version() external view override returns (uint256){
        return 1;
    }

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
    external
    view
    override
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ){
        // 1 gas = 100 gwei
        return (1, 100, 1, 1, 1);
    }

    function latestRoundData()
    external
    view
    override
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ){
        // 1 gas = 100 gwei
        return (1, 100, 1, 1, 1);
    }
}
