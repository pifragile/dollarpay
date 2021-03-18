// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.3;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


/**
 * @dev Implemnatation of an ERC20 compliant contract that facilitates dollar equivalent payments.
 * Users can deposit ether into the contract and from that point on they can interact with the contract
 * as if they were dealing with dollars.
 * In other words, the internal representation of value in in ether but the interface of the contract is in dollar.
 * Decimals of this contract is 2, so one can think of all the values as if the unit were cents.
 */

contract Dollarpay is IERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    // multiplier used to convert from USD cents to wei
    uint256 _priceMultiplier;

    AggregatorV3Interface internal priceFeed;

    constructor(address oracleAddress) {
        priceFeed = AggregatorV3Interface(oracleAddress);
        _decimals = 2;
        setPriceMultiplier();
        _name = "Dollarpay";
        _symbol = "DOP";
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function deposit() public payable returns (bool){
        _balances[msg.sender] += msg.value;
        return true;
    }


    function withdrawAll() public returns (bool){
        msg.sender.transfer(_balances[msg.sender]);
        _balances[msg.sender] = 0;
        return true;
    }

    function getLatestPrice() internal view returns (int) {
        (,int price,,,) = priceFeed.latestRoundData();
        return price;
    }

    /**
    * @dev Sets _priceMultiplier according to the latest oracle data
    */
    function setPriceMultiplier() public {
        int256 priceSigned = getLatestPrice();
        uint256 oracleDecimals = priceFeed.decimals();
        require(priceSigned > 0);
        uint256 price = uint256(priceSigned);

        // 1 ether = 10**18 wei
        // 10**18 wei = price/10**oracleDecimals usd
        // 10**18 wei = price/10**(oracleDecimals - 2) usd cents
        // 10**(18+decimals - 2)/price wei = 1 usd cent
        _priceMultiplier = ((10 ** (16 + oracleDecimals)) / price);
    }


    function totalSupply() public view override returns (uint256) {
        return address(this).balance / _priceMultiplier;
    }


    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account] / _priceMultiplier;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender] / _priceMultiplier;
    }


    function transfer(address recipient, uint256 amount) public override returns (bool){
        uint256 dollarEquivalentAmount = amount * _priceMultiplier;
        _transfer(msg.sender, recipient, dollarEquivalentAmount);
        return true;
    }

    function transferExternal(address recipient, uint256 amount) public payable returns (bool){
        require(recipient != address(0), "transfer to the zero address");
        uint256 dollarEquivalentAmount = amount * _priceMultiplier;
        require(msg.value >= dollarEquivalentAmount);
        _balances[recipient] = _balances[recipient].add(dollarEquivalentAmount);
        msg.sender.transfer(msg.value - dollarEquivalentAmount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 dollarEquivalentAmount = amount * _priceMultiplier;
        _transfer(sender, recipient, dollarEquivalentAmount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(dollarEquivalentAmount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        uint256 dollarEquivalentAmount = amount * _priceMultiplier;
        _approve(msg.sender, spender, dollarEquivalentAmount);
        return true;
    }


    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

}
