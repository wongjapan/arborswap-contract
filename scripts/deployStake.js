const hre = require("hardhat");
const {ethers} = require("hardhat");

const stakeToken = "0x8655e717fA4157e1099F61bA261c2Cd7b121d661";
const rewardToken = "0x8655e717fA4157e1099F61bA261c2Cd7b121d661";
const rewardN = "100";
const rewardD = "1000000";

async function main() {
  const ArborsStaking = await ethers.getContractFactory("ArborsStaking");
  const arborsStaking = await ArborsStaking.deploy(stakeToken, rewardToken, rewardN, rewardD);

  await arborsStaking.deployed();

  console.log("ArborsStaking deployed to:", arborsStaking.address);

  try {
    await hre.run("verify", {
      address: arborsStaking.address,
      constructorArgsParams: [stakeToken, rewardToken, rewardN, rewardD],
    });
  } catch (error) {
    console.error(error);
    console.log(`Smart contract at address ${arborsStaking.address} is already verified`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
