const hre = require('hardhat')

async function main() {
  const [deployer] = await hre.ethers.getSigners()

  console.log(
    'Deploying contracts with the account:',
    deployer.address,
  )
  const FouTou = await hre.ethers.getContractFactory('FouTou')
  const foutou = await FouTou.deploy()

  await foutou.deployed()

  console.log('Wae portal deployed to:', foutou.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })