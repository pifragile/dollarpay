const {expect} = require("chai");

let dollarpay

async function setupContracts() {
    const Oracle = await ethers.getContractFactory("OracleMock");
    oracle = await Oracle.deploy();
    await oracle.deployed();

    const Dollarpay = await ethers.getContractFactory("Dollarpay");
    dollarpay = await Dollarpay.deploy(oracle.address);
    await dollarpay.deployed();
}

describe("Dollarpay", function () {
    before('setup Dollarpay contract', setupContracts)

    it("be able to transfer ethers in dollar equivalent", async function () {
        // deposit 1 ether
        await dollarpay.deposit({value: '1000000000000000000'})
        expect(parseInt(await web3.eth.getBalance(dollarpay.address))).to.be.equal(1000000000000000000,)
        const {address} = await web3.eth.accounts.create()
        await dollarpay.transferDollarEquivalent(address, 3)

        expect(parseInt(await web3.eth.getBalance(address))).to.be.closeTo(500000000000000000, 2)
        expect(parseInt(await web3.eth.getBalance(dollarpay.address))).to.be.closeTo(500000000000000000, 2)
    });

    it("not allow payments if you dont have enough balance", async function () {
        const {address} = await web3.eth.accounts.create()
        expect(dollarpay.transferDollarEquivalent(address, 10)).to.be.revertedWith("Not enough Balance")
    });
});
