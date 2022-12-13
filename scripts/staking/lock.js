const hre = require("hardhat");
const {ethers} = require("hardhat");
// const {REWARD_WALLET, TREASURY} = require("./constants/address");

const stakeToken = "0xFAe063159b4d83d8491271a165eECa5632E4c288";
const rewardToken = "0xFAe063159b4d83d8491271a165eECa5632E4c288";
const rate = "10";
const locktime = "60";

async function main() {
  const ArborsStakingWithFixedLockTime = await ethers.getContractFactory("ArborsStakingWithDividendAndFixedLockTime");
  const arborsStakingWithFixedLockTime = await ArborsStakingWithFixedLockTime.deploy(
    stakeToken,
    rewardToken,
    locktime,
    rate
  );

  await arborsStakingWithFixedLockTime.deployed();

  console.log("ArborsStakingWithFixedLockTime deployed to:", arborsStakingWithFixedLockTime.address);

  // try {
  //   await hre.run("verify", {
  //     address: arborsStakingWithFixedLockTime.address,
  //     constructorArgsParams: [stakeToken, rewardToken, locktime, rate],
  //   });
  // } catch (error) {
  //   console.error(error);
  //   console.log(`Smart contract at address ${arborsStakingWithFixedLockTime.address} is already verified`);
  // }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
