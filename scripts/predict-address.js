const { ethers } = require('hardhat')
const { getContractAddress } = require('@ethersproject/address')

async function main() {
  const [owner] = await ethers.getSigners()

  const transactionCount = await owner.getTransactionCount()

  const futureAddress = getContractAddress({
    from: owner.address,
    nonce: transactionCount
  });

  console.log(`\nnext address: ${futureAddress}\n`);
}

main();