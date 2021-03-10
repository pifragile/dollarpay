pragma solidity ^0.7.3;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract OracleMock {
    function decimals() external view returns (uint8){
        return 8;
    }

    function description() external view returns (string memory){
        return "Mock Description";
    }

    function version() external view returns (uint256){
        return 1;
    }

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
    external
    view
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ){
        // 1 ether = 6 dollars
        return (1, 600000000, 1, 1, 1);
    }

    function latestRoundData()
    external
    view
    returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ){
        // 1 ether = 6 dollars
        return (1, 600000000, 1, 1, 1);
    }
}
