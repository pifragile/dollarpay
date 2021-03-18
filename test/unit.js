const {expect} = require("chai");
const {getBalance} = require("../utils/utils");

let dollarpay

async function setupContracts() {
    const Oracle = await ethers.getContractFactory("OracleMock")
    const oracle = await Oracle.deploy()
    await oracle.deployed()

    const Dollarpay = await ethers.getContractFactory("Dollarpay")
    dollarpay = await Dollarpay.deploy(oracle.address)
    await dollarpay.deployed()
}

describe("Dollarpay", function () {
    beforeEach("setup Dollarpay contract", setupContracts)


    it("should have _decimals = 2", async function () {
        expect(await dollarpay.decimals()).to.be.equal(2);
    });

    it("should have deposit functionality", async function () {
        const [owner] = await ethers.getSigners()
        await dollarpay.deposit({value: String(10 ** 18)})
        expect(await getBalance(dollarpay.address)).to.be.equal(10 ** 18)
        expect(parseInt(await dollarpay.balanceOf(owner.address))).to.be.equal(600)
    });

    it("should be able to withdraw all funds", async function () {
        const [owner, addr1] = await ethers.getSigners()
        let balance = await getBalance(addr1.address)
        let gasPrice, gasLimit
        // deposit 1 ether
        ({gasPrice, gasLimit} = await dollarpay.connect(addr1).deposit({value: "1000000000000000000"}))

        let newBalance = await getBalance(addr1.address)
        expect(newBalance).to.be.greaterThan(balance - 10 ** 18 - gasLimit * gasPrice)
        expect(newBalance).to.be.lessThan(balance - 10 ** 18)

        balance = await getBalance(addr1.address);
        ({gasPrice, gasLimit} = await dollarpay.connect(addr1).withdrawAll())
        newBalance = await getBalance(addr1.address)
        expect(newBalance).to.be.greaterThan(balance + 10 ** 18 - gasLimit * gasPrice)
        expect(newBalance).to.be.lessThan(balance + 10 ** 18)
    });

    it("should have functionality to set the latest Price", async function () {
        const Oracle = await ethers.getContractFactory("RandomPriceOracleMock")
        const oracle = await Oracle.deploy()
        await oracle.deployed()

        const Dollarpay = await ethers.getContractFactory("Dollarpay")
        dollarpay = await Dollarpay.deploy(oracle.address)
        await dollarpay.deployed()

        const [owner] = await ethers.getSigners()
        await dollarpay.deposit({value: String(10 ** 18)})
        const balance = parseInt(await dollarpay.balanceOf(owner.address))
        await dollarpay.setPriceMultiplier()
        expect(parseInt(await dollarpay.balanceOf(owner.address))).not.to.be.equal(balance)
    });

    it("should calculate total supply correctly", async function () {
        const [owner] = await ethers.getSigners()
        await dollarpay.deposit({value: String(10 ** 18)})
        expect(parseInt(await dollarpay.totalSupply())).to.be.equal(600)
        await dollarpay.deposit({value: String(10 ** 18)})
        expect(parseInt(await dollarpay.totalSupply())).to.be.equal(1200)
    });

    it("should calculate balanceOf supply correctly", async function () {
        const [owner] = await ethers.getSigners()
        await dollarpay.deposit({value: String(10 ** 18)})
        expect(parseInt(await dollarpay.balanceOf(owner.address))).to.be.equal(600)
        await dollarpay.deposit({value: String(10 ** 18)})
        expect(parseInt(await dollarpay.balanceOf(owner.address))).to.be.equal(1200)
    });

    it("should handle allowances correctly", async function () {
        const [owner, account1] = await ethers.getSigners()
        await dollarpay.approve(account1.address, 1000)
        expect(parseInt(await dollarpay.allowance(owner.address, account1.address))).to.be.equal(1000);
    });

    it("should have transfer functionality", async function () {
        const [owner, account1] = await ethers.getSigners()
        await dollarpay.deposit({value: String(10 ** 18)})
        await dollarpay.transfer(account1.address, 400)
        expect(parseInt(await dollarpay.balanceOf(account1.address))).to.be.equal(400)
        expect(parseInt(await dollarpay.balanceOf(owner.address))).to.be.equal(200)
        await dollarpay.transfer(account1.address, 200)
    });

    it("should fail transfer if not enough balance", async function () {
        const [owner, account1] = await ethers.getSigners()
        await dollarpay.deposit({value: String(10 ** 18)})
        expect(dollarpay.transfer(account1.address, 601)).to.be.revertedWith("ERC20: transfer amount exceeds balance")
    });

    it("should have transferExternal functionality", async function () {
        const [owner, account1] = await ethers.getSigners()
        let balance = await getBalance(owner.address)
        let gasPrice, gasLimit;
        // send 1 ether and transfer 300 cents (0.5 ether) to account1
        ({gasPrice, gasLimit} = await dollarpay.transferExternal(account1.address, 300, {value: String(10 ** 18)}))


        let newBalance = await getBalance(owner.address)
        // should have received 0.5 ether back
        expect(newBalance).to.be.greaterThan(balance - 5 * 10 ** 17 - gasLimit * gasPrice)
        expect(newBalance).to.be.lessThan(balance - 5 * 10 ** 17)

        expect(parseInt(await dollarpay.balanceOf(account1.address))).to.be.equal(300)
    });

    it("should have transferFrom functionality", async function () {
        const [owner, account1, account2] = await ethers.getSigners()
        await dollarpay.connect(account1).approve(account2.address, 300)
        expect(dollarpay.connect(account2).transferFrom(account1.address, owner.address, 300)).to.be.revertedWith("ERC20: transfer amount exceeds balance")
        await dollarpay.connect(account1).deposit({value: String(10 ** 18)})
        expect(dollarpay.connect(account2).transferFrom(account1.address, owner.address, 301)).to.be.revertedWith("ERC20: transfer amount exceeds allowance")
        await dollarpay.connect(account2).transferFrom(account1.address, owner.address, 200)

        expect(parseInt(await dollarpay.balanceOf(account1.address))).to.be.equal(400)
        expect(parseInt(await dollarpay.balanceOf(account2.address))).to.be.equal(0)
        expect(parseInt(await dollarpay.balanceOf(owner.address))).to.be.equal(200)
    });
});
