async function getBalance(addr) {
    return parseInt(await web3.eth.getBalance(addr))
}

module.exports = {getBalance}