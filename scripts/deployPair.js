const hre = require("hardhat");
const {ethers} = require("hardhat");
const {FEE_TO_SETTER} = require("./constants/address");

const {wbnb, factory} = require("../config");

const FACTORY_ADDRESS = "0x141aaCFcab0B68e261459162e02Bf01F34Ee69ce";
const WBNB_ADDRESS = "0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c";

async function main() {
  const ArborSwapPair = await ethers.getContractFactory("ArborSwapPair");
  const arborSwapPair = await ArborSwapPair.deploy();

  await arborSwapPair.deployed();

  console.log("ArborSwapPair deployed to:", arborSwapPair.address);

  try {
    await hre.run("verify", {
      address: arborSwapPair.address,
    });
  } catch (error) {
    console.error(error);
    console.log(`Smart contract at address ${arborSwapPair.address} is already verified`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
