const hre = require("hardhat");
const {ethers} = require("hardhat");
const {FEE_TO_SETTER} = require("./constants/address");
const {wbnb} = require("../config");

async function main() {
  // const ArborSwapFactory = await ethers.getContractFactory("GooseBumpsSwapFactory");
  // const arborSwapFactory = await ArborSwapFactory.deploy(FEE_TO_SETTER);

  // await arborSwapFactory.deployed();

  // console.log("GooseBumpsSwapFactory deployed to:", arborSwapFactory.address);

  // const pairCodeHash = await arborSwapFactory.pairCodeHash();
  // console.log("pairCodeHash:", pairCodeHash);

  //   try {
  //     await hre.run("verify", {
  //       address: arborSwapFactory.address,
  //       constructorArgsParams: [FEE_TO_SETTER],
  //     });
  //   } catch (error) {
  //     console.error(error);
  //     console.log(`Smart contract at address ${arborSwapFactory.address} is already verified`);
  //   }

  const ArborSwapRouter02 = await ethers.getContractFactory("GooseBumpsSwapRouter02");
  const arborSwapRouter02 = await ArborSwapRouter02.deploy("0xD3c5FF3f6C4E9Aa876E563f4cb04d3020CFC8Ad9", wbnb.rba);

  await arborSwapRouter02.deployed();

  console.log("GooseBumpsSwapRouter02 deployed to:", arborSwapRouter02.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
