const hre = require("hardhat");
const {ethers} = require("hardhat");
const {FEE_TO_SETTER} = require("./constants/address");
const {wbnb} = require("../config");

async function main() {
  const defaultRouter = "0x2fAe743821Bbc2CfD025C7E6B3Ee01ae202dd48B";
  const externalRouter = "0xcEd0eF810B549E5a934c8ac1AA08a7dC348c0ea9";
  const treasury = "0x9224513121f576441DD9De66d4E598aAD2B433A9";
  const defaultFee = 100;
  const externalFee = 100;

  const DexContract = await ethers.getContractFactory("DEXManagement");
  const dexContract = await DexContract.deploy(defaultRouter, externalRouter, treasury, defaultFee, externalFee);

  await dexContract.deployed();

  console.log("DEXManagement deployed to:", dexContract.address);

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
