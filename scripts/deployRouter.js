const hre = require("hardhat");
const {ethers} = require("hardhat");
// const {FEE_TO_SETTER} = require("./constants/address");

// const {wbnb, factory} = require("../config");

const FACTORY_ADDRESS = "0x0438309c81376d90D191Ab2Cdd464716B3c69B54";
const WBNB_ADDRESS = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";

async function main() {
  const ArborSwapRouter02 = await ethers.getContractFactory("ArborSwapRouter02");
  const arborSwapRouter02 = await ArborSwapRouter02.deploy(FACTORY_ADDRESS, WBNB_ADDRESS);

  await arborSwapRouter02.deployed();

  console.log("ArborSwapRouter02 deployed to:", arborSwapRouter02.address);

  try {
    await hre.run("verify", {
      address: arborSwapRouter02.address,
      constructorArgsParams: [FACTORY_ADDRESS, WBNB_ADDRESS],
    });
  } catch (error) {
    console.error(error);
    console.log(`Smart contract at address ${arborSwapRouter02.address} is already verified`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
