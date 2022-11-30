const hre = require("hardhat");
const {ethers} = require("hardhat");
const {FEE_TO_SETTER} = require("./constants/address");
const {wbnb} = require("../config");

async function main() {
  const ArborSwapFactory = await ethers.getContractFactory("ArborSwapFactory");
  const arborSwapFactory = await ArborSwapFactory.deploy(FEE_TO_SETTER);

  await arborSwapFactory.deployed();

  console.log("ArborSwapFactory deployed to:", arborSwapFactory.address);

  const pairCodeHash = await arborSwapFactory.pairCodeHash();
  console.log("pairCodeHash:", pairCodeHash);

  //   try {
  //     await hre.run("verify", {
  //       address: arborSwapFactory.address,
  //       constructorArgsParams: [FEE_TO_SETTER],
  //     });
  //   } catch (error) {
  //     console.error(error);
  //     console.log(`Smart contract at address ${arborSwapFactory.address} is already verified`);
  //   }

  const ArborSwapRouter02 = await ethers.getContractFactory("ArborSwapRouter02");
  const arborSwapRouter02 = await ArborSwapRouter02.deploy(arborSwapFactory.address, wbnb.rba);

  await arborSwapRouter02.deployed();

  console.log("ArborSwapRouter02 deployed to:", arborSwapRouter02.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
