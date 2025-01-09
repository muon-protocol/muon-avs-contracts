import hre, { ethers, upgrades } from "hardhat";

async function run() {
  let serviceManager = "";
  let thresholdWeight = "";
  let quorum = "";
  let delegationManager = "";
  let deployer = "0x1c5214269FEbA6656f558fB08a75A6190Be796d3";
  const factory = await ethers.getContractFactory("StakeRegistry", {
    signer: await ethers.getSigner(deployer),
  });
  const proxy = await upgrades.deployProxy(
    factory, 
    [
      serviceManager,
      thresholdWeight,
      quorum
    ],
    { 
      constructorArgs: [delegationManager] 
    }
  );

  await proxy.deployed();
  try {
    await hre.run("verify:verify", {
      address: proxy.address
    });
  } catch {
    console.log("Failed to verify");
  }
  console.log("StakeRegistry deployed at:", proxy.address);
}

run()
  .then(() => {
    console.log("done");
  })
  .catch(console.log);
