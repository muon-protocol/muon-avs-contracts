import { ethers, upgrades } from "hardhat";

const addresses = {
  mainnet: {
    delegationManager: "0x39053D51B77DC0d36036Fc1fCc8Cb819df8Ef37A",
    avsDirectory: "0x135DDa560e946695d6f155dACaFC6f1F25C1F5AF",
    rewardsCoordinator: "0x7750d328b314EfFa365A0402CcfD489B80B0adda",
    strategies: [
      {
        name: "cbETH",
        strategy: "0x54945180dB7943c0ed0FEE7EdaB2Bd24620256bc",
      },
      {
        name: "stETH",
        strategy: "0x93c4b944D05dfe6df7645A86cd2206016c51564D",
      },
      {
        name: "rETH",
        strategy: "0x1BeE69b7dFFfA4E2d53C2a2Df135C388AD25dCD2",
      },
      {
        name: "ETHx",
        strategy: "0x9d7eD45EE2E8FC5482fa2428f15C971e6369011d",
      },
      {
        name: "ankrETH",
        strategy: "0x13760F50a9d7377e4F20CB8CF9e4c26586c658ff",
      },
      {
        name: "OETH",
        strategy: "0xa4C637e0F704745D182e4D38cAb7E7485321d059",
      },
      {
        name: "osETH",
        strategy: "0x57ba429517c3473B6d34CA9aCd56c0e735b94c02",
      },
      {
        name: "swETH",
        strategy: "0x0Fe4F44beE93503346A3Ac9EE5A26b130a5796d6",
      },
      {
        name: "wBETH",
        strategy: "0x7CA911E83dabf90C90dD3De5411a10F1A6112184",
      },
      {
        name: "sfrxETH",
        strategy: "0x8CA7A5d6f3acd3A7A8bC468a8CD0FB14B6BD28b6",
      },
      {
        name: "lsETH",
        strategy: "0xAe60d8180437b5C34bB956822ac2710972584473",
      },
      {
        name: "mETH",
        strategy: "0x298aFB19A105D59E74658C4C334Ff360BadE6dd2",
      },
      {
        name: "EigenStrategy (EIGEN)",
        strategy: "0xaCB55C530Acdb2849e6d4f36992Cd8c9D50ED8F7",
      },
      {
        name: "Beacon Chain ETH",
        strategy: "0xbeaC0eeEeeeeEEeEeEEEEeeEEeEeeeEeeEEBEaC0",
      },
    ],
  },
  holesky: {
    delegationManager: "0xA44151489861Fe9e3055d95adC98FbD462B948e7",
    avsDirectory: "0x055733000064333CaDDbC92763c58BF0192fFeBf",
    rewardsCoordinator: "0xAcc1fb458a1317E886dB376Fc8141540537E68fE",
    strategies: [
      {
        name: "stETH",
        strategy: "0x7D704507b76571a51d9caE8AdDAbBFd0ba0e63d3",
      },
      {
        name: "rETH",
        strategy: "0x3A8fBdf9e77DFc25d09741f51d3E181b25d0c4E0",
      },
      {
        name: "WETH",
        strategy: "0x80528D6e9A2BAbFc766965E0E26d5aB08D9CFaF9",
      },
      {
        name: "lsETH",
        strategy: "0x05037A81BD7B4C9E0F7B430f1F2A22c31a2FD943",
      },
      {
        name: "sfrxETH",
        strategy: "0x9281ff96637710Cd9A5CAcce9c6FAD8C9F54631c",
      },
      {
        name: "ETHx",
        strategy: "0x31B6F59e1627cEfC9fA174aD03859fC337666af7",
      },
      {
        name: "osETH",
        strategy: "0x46281E3B7fDcACdBa44CADf069a94a588Fd4C6Ef",
      },
      {
        name: "cbETH",
        strategy: "0x70EB4D3c164a6B4A5f908D4FBb5a9cAfFb66bAB6",
      },
      {
        name: "mETH",
        strategy: "0xaccc5A86732BE85b5012e8614AF237801636F8e5",
      },
      {
        name: "ankrETH",
        strategy: "0x7673a47463F80c6a3553Db9E54c8cDcd5313d0ac",
      },
      {
        name: "reALT",
        strategy: "0xAD76D205564f955A9c18103C4422D1Cd94016899",
      },
      {
        name: "EO",
        strategy: "0x78dBcbEF8fF94eC7F631c23d38d197744a323868",
      },
      {
        name: "EigenStrategy (EIGEN)",
        strategy: "0x43252609bff8a13dFe5e057097f2f45A24387a84",
      },
      {
        name: "Beacon Chain ETH",
        strategy: "0xbeaC0eeEeeeeEEeEeEEEEeeEEeEeeeEeeEEBEaC0",
      },
    ],
  },
};

async function main() {
  const [deployer] = await ethers.getSigners();

  const StakeRegistryContract =
    await ethers.getContractFactory("MuonStakeRegistry");

  const StakeRegistryImpl = await StakeRegistryContract.deploy(
    addresses[hre.network.name].delegationManager
  );
  await StakeRegistryImpl.deployed();
  console.log(
    "StakeRegistry implementation deployed at:",
    StakeRegistryImpl.address
  );

  const proxyAdminAddress = "0xa6102581Fd03915CD70810130f1B85Ea5E297e0b"; // Replace with deployed ProxyAdmin address
  const proxyAddress = "0x8D4DA67929Cfa5a0Eab573Ea57225b1D8286742A"; // Replace with deployed proxy address

  console.log("Upgrading proxy to new implementation...");

   // Get the ProxyAdmin contract instance
   const ProxyAdmin = await ethers.getContractAt("ProxyAdmin", proxyAdminAddress, deployer);

   // Upgrade the proxy to the new implementation
   const tx = await ProxyAdmin.upgradeAndCall(proxyAddress, StakeRegistryImpl.address, "0x");
   await tx.wait();

  console.log("Proxy upgraded successfully!");

  try {
    await hre.run("verify:verify", {
      address: proxyAddress,
      constructorArguments: [
        addresses[hre.network.name].delegationManager
      ],
    });
  } catch {
    console.log("Failed to verify");
  }
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
