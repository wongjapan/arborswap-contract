const hre = require("hardhat");
const {ethers} = require("hardhat");
const {FEE_TO_SETTER} = require("./constants/address");

async function main() {
  const Multicall2 = await ethers.getContractFactory("Multicall2");
  const multicall = await Multicall2.deploy();

  await multicall.deployed();

  console.log("Multicall2 deployed to:", multicall.address);

  //   const pairCodeHash = await arborSwapFactory.pairCodeHash();
  //   console.log("pairCodeHash:", pairCodeHash);

  //   try {
  //     await hre.run("verify", {
  //       address: arborSwapFactory.address,
  //       constructorArgsParams: [FEE_TO_SETTER],
  //     });
  //   } catch (error) {
  //     console.error(error);
  //     console.log(`Smart contract at address ${arborSwapFactory.address} is already verified`);
  //   }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
