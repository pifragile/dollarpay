const {expect} = require("chai");
const {getBalance} = require("../utils/utils");

let dollarpay

async function setupContracts() {
    const Oracle = await ethers.getContractFactory("OracleMock")
    oracle = await Oracle.deploy()
    await oracle.deployed()

    const Dollarpay = await ethers.getContractFactory("Dollarpay")
    dollarpay = await Dollarpay.deploy(oracle.address)
    await dollarpay.deployed()
}

describe("Dollarpay", function () {
    before('setup Dollarpay contract', setupContracts)

    it("be able to transfer ethers in dollar equivalent", async function () {
        // deposit 1 ether
        const [owner, addr1] = await ethers.getSigners()

        await dollarpay.connect(addr1).deposit({value: '1000000000000000000'})
        expect(await getBalance(dollarpay.address)).to.be.equal(10 ** 18,)
        const {address} = await web3.eth.accounts.create()
        await dollarpay.connect(addr1).transferDollarEquivalent(address, 3)

        expect(await getBalance(address)).to.be.closeTo(5 * 10 ** 17, 2)
        expect(await getBalance(dollarpay.address)).to.be.closeTo(5 * 10 ** 17, 2)
    });

    it("not allow payments if you dont have enough balance", async function () {
        const {address} = await web3.eth.accounts.create()
        expect(dollarpay.transferDollarEquivalent(address, 10)).to.be.revertedWith("Not enough Balance")
    });
});
