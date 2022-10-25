const hre = require("hardhat");
const {ethers} = require("hardhat");
const {REWARD_WALLET, TREASURY} = require("./constants/address");

const stakeToken = "0x8655e717fA4157e1099F61bA261c2Cd7b121d661";
const rewardToken = "0x8655e717fA4157e1099F61bA261c2Cd7b121d661";
const rate = "5";
const locktime = "1000000";

async function main() {
  const ArborsStakingWithFixedLockTime = await ethers.getContractFactory("ArborsStakingWithFixedLockTime");
  const arborsStakingWithFixedLockTime = await ArborsStakingWithFixedLockTime.deploy(
    stakeToken,
    rewardToken,
    rewardN,
    rewardD
  );

  await arborsStakingWithFixedLockTime.deployed();

  console.log("ArborsStakingWithFixedLockTime deployed to:", arborsStakingWithFixedLockTime.address);

  try {
    await hre.run("verify", {
      address: arborsStakingWithFixedLockTime.address,
      constructorArgsParams: [stakeToken, rewardToken, rewardN, rewardD],
    });
  } catch (error) {
    console.error(error);
    console.log(`Smart contract at address ${arborsStakingWithFixedLockTime.address} is already verified`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
