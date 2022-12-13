const hre = require("hardhat");
const {ethers} = require("hardhat");

const stakeToken = "0xFAe063159b4d83d8491271a165eECa5632E4c288";
const rewardToken = "0xFAe063159b4d83d8491271a165eECa5632E4c288";
const rate = "5";

async function main() {
  const ArborsStaking = await ethers.getContractFactory("ArborsStakingWithDividend");
  const arborsStaking = await ArborsStaking.deploy(stakeToken, rewardToken, rate);

  await arborsStaking.deployed();

  console.log("ArborsStaking deployed to:", arborsStaking.address);

  // try {
  //   await hre.run("verify", {
  //     address: arborsStaking.address,
  //     constructorArgsParams: [stakeToken, rewardToken, rate],
  //   });
  // } catch (error) {
  //   console.error(error);
  //   console.log(`Smart contract at address ${arborsStaking.address} is already verified`);
  // }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
