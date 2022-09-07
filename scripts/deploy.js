const { ethers } = require("hardhat");
const { FEE_TO_SETTER } = require("./constants/address");

async function main() {
  const ArborSwapFactory = await ethers.getContractFactory("ArborSwapFactory");
  const arborSwapFactory = await ArborSwapFactory.deploy(FEE_TO_SETTER);

  await arborSwapFactory.deployed();

  console.log("ArborSwapFactory deployed to:", arborSwapFactory.address);

  const pairCodeHash = await arborSwapFactory.pairCodeHash();
  console.log("pairCodeHash:", pairCodeHash);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
