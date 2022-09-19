const hre = require("hardhat");
const {ethers} = require("hardhat");
const {FEE_TO_SETTER} = require("./constants/address");

const {wbnb, factory} = require("../config");

async function main() {
  const ArborSwapRouter02 = await ethers.getContractFactory("ArborSwapRouter02");
  const arborSwapRouter02 = await ArborSwapRouter02.deploy(factory.bsc_testnet, wbnb.bsc_testnet);

  await arborSwapRouter02.deployed();

  console.log("ArborSwapRouter02 deployed to:", arborSwapRouter02.address);

  try {
    await hre.run("verify", {
      address: arborSwapRouter02.address,
      constructorArgsParams: [factory.bsc_testnet, wbnb.bsc_testnet],
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
