/**
 * @type import("hardhat/config").HardhatUserConfig
 */

require("@nomiclabs/hardhat-ethers")
require("@nomiclabs/hardhat-waffle")
require("@nomiclabs/hardhat-web3")
require("dotenv").config()

module.exports = {
    networks: {
        kovan: {
            url: `https://eth-kovan.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
            accounts: [`0x${process.env.KOVAN_PRIVATE_KEY}`]
        }
    },
    solidity: "0.7.3",
};


task("deploy:dollarpay", "Deploys the Dollarpay smart contract")
    .addParam("oracle", "The price feed oracle address")
    .setAction(async taskArgs => {
        const Dollarpay = await ethers.getContractFactory("Dollarpay");
        const dollarpay = await Dollarpay.deploy(taskArgs.oracle);
        await dollarpay.deployed();

        console.log("Dollarpay deployed to:", dollarpay.address);
    });
