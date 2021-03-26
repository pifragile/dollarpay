// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.3;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

/**
 * @dev This mock oracle is used for testing the setPriceMultiplierFunction of Dollarpay
 * We are aware that the pattern with the randomness is not optimal, but a deterministic soulution
 * is not possible at the moment as the getRoundData and latestRoundData are defined as view
 * by AggregatorV3Interface.
 */
contract RandomPriceFeedMock is AggregatorV3Interface {

    function decimals() external view override returns (uint8){
        return 8;
    }

    function description() external view override returns (string memory){
        return "Mock Description";
    }

    function version() external view override returns (uint256){
        return 1;
    }

    function random() internal view returns (int256) {
        return (int(keccak256(abi.encodePacked(block.difficulty, block.timestamp))) % 100000000) + 100000000;
    }

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
        return (1, random(), 1, 1, 1);
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
        return (1, random(), 1, 1, 1);
    }
}
