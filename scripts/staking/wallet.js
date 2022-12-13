const hre = require("hardhat");
const {ethers} = require("hardhat");

const mainToken = "0xFAe063159b4d83d8491271a165eECa5632E4c288";
const stakingContract = "0x907be116635eF8F3F360f74A46c10F81434B6908";
// const rate = "5";

async function main() {
  const ArborStakingWallet = await ethers.getContractFactory("ArborStakingWallet");
  const arborsStakingWallet = await ArborStakingWallet.deploy(mainToken, stakingContract);

  await arborsStakingWallet.deployed();

  const arborsStakingWallet2 = await ArborStakingWallet.deploy(mainToken, stakingContract);
  await arborsStakingWallet2.deployed();

  console.log("RewardWallet deployed to:", arborsStakingWallet.address);
  console.log("TreasuryWallet deployed to:", arborsStakingWallet2.address);

  //   try {
  //     await hre.run("verify", {
  //       address: arborsStakingWallet.address,
  //       constructorArgsParams: [mainToken, stakingContract],
  //     });
  //     await hre.run("verify", {
  //       address: arborsStakingWallet2.address,
  //       constructorArgsParams: [mainToken, stakingContract],
  //     });
  //   } catch (error) {
  //     console.error(error);
  //     console.log(`Smart contract at address ${arborsStakingWallet.address} is already verified`);
  //   }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
