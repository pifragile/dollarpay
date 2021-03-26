import "../Dollarpay.sol";
pragma solidity ^0.7.3;

contract ExposedDollarpay is Dollarpay {
    constructor(address priceFeedAddress, address gasPriceFeedAddress, uint256 initialFee) public Dollarpay(priceFeedAddress, gasPriceFeedAddress, initialFee) {}

    function update_price_and_refund_gas_cost(address payable sender) public {
        _update_price_and_refund_gas_cost(sender);
    }
}