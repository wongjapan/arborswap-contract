const hre = require("hardhat");
const {ethers} = require("hardhat");

const mainToken = "0x6Ef84972B6d58e78b9a4512D808eb87F18A308a6";
const stakingContract = "0xB9292782a4d96Fe4feC35C4603079fE33862f54d";
// const rate = "5";

async function main() {
  const ArborStakingWallet = await ethers.getContractFactory("ArborStakingWallet");
  const arborsStakingWallet = await ArborStakingWallet.deploy(mainToken, stakingContract);

  await arborsStakingWallet.deployed();

  console.log("ArborStakingWallet deployed to:", arborsStakingWallet.address);

  try {
    await hre.run("verify", {
      address: arborsStakingWallet.address,
      constructorArgsParams: [mainToken, stakingContract],
    });
  } catch (error) {
    console.error(error);
    console.log(`Smart contract at address ${arborsStakingWallet.address} is already verified`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
