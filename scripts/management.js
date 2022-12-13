const hre = require("hardhat");
const {ethers} = require("hardhat");
const {FEE_TO_SETTER} = require("./constants/address");
const {wbnb} = require("../config");

async function main() {
  const defaultRouter = "0x3027Ae348394349886f963D35786e5F468A221DE";
  const externalRouter = "0x10ED43C718714eb63d5aA57B78B54704E256024E";
  const treasury = "0x3dd61427dbbC0E980FD65bAE7F84a297c1Cd4eED";
  const defaultFee = "10"; // 0.1%
  const externalFee = "5"; // 0.05%

  const DexContract = await ethers.getContractFactory("DEXManagement");
  const dexContract = await DexContract.deploy(defaultRouter, externalRouter, treasury, defaultFee, externalFee);

  await dexContract.deployed();

  console.log("DEXManagement deployed to:", dexContract.address);

  try {
    await hre.run("verify", {
      address: dexContract.address,
      constructorArgsParams: [defaultRouter, externalRouter, treasury, defaultFee, externalFee],
    });
  } catch (error) {
    console.error(error);
    console.log(`Smart contract at address ${dexContract.address} is already verified`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
