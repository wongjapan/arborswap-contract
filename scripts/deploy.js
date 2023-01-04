const hre = require("hardhat");
const {ethers} = require("hardhat");
// const {FEE_TO_SETTER} = require("./constants/address");

const FEE_TO_SETTER = "0x2e86870A94BEbeed445e0C73eA2230a7029C4812";
const FEE_TO = "0x3dd61427dbbC0E980FD65bAE7F84a297c1Cd4eED";

async function main() {
  const ArborSwapFactory = await ethers.getContractFactory("ArborSwapFactory");
  const arborSwapFactory = await ArborSwapFactory.deploy(FEE_TO_SETTER, FEE_TO);

  await arborSwapFactory.deployed();

  console.log("ArborSwapFactory deployed to:", arborSwapFactory.address);

  const pairCodeHash = await arborSwapFactory.pairCodeHash();
  console.log("pairCodeHash:", pairCodeHash);

  // try {
  //   await hre.run("verify", {
  //     address: arborSwapFactory.address,
  //     constructorArgsParams: [FEE_TO_SETTER, FEE_TO],
  //   });
  // } catch (error) {
  //   console.error(error);
  //   console.log(`Smart contract at address ${arborSwapFactory.address} is already verified`);
  // }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
