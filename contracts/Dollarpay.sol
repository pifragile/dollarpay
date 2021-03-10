pragma solidity ^0.7.3;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract Dollarpay {
    mapping(address => uint) private balances;

    AggregatorV3Interface internal priceFeed;

    constructor(address oracleAddress) public {
        priceFeed = AggregatorV3Interface(oracleAddress);
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function getLatestPrice() public view returns (int) {
        (
        uint80 roundID,
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }

    function transferDollarEquivalent(address payable receiver, uint256 amount) public {
        int256 priceSigned = getLatestPrice();
        uint256 decimals = priceFeed.decimals();
        require(priceSigned > 0);
        uint256 price = uint256(priceSigned);

        // 1 ether = 10**18 wei
        // 10**18 wei = price/10**decimals
        // 10**(18+decimals)/price wei = 1 usd
        uint256 dollarEquivalentAmount = amount * ((10**(18+decimals)) / price);
        require(balances[msg.sender] >= dollarEquivalentAmount, "Not enough Balance");
        receiver.transfer(dollarEquivalentAmount);
        balances[msg.sender] -= dollarEquivalentAmount;
    }

    function withdrawAll() public {
        msg.sender.transfer(balances[msg.sender]);
        balances[msg.sender] = 0;
    }
}
