const hre = require("hardhat");
const {ethers} = require("hardhat");

const normalStakeAddress = "0x1bC090Ed5dFF341ed3fd31332E99993584C7693e";
const lockStakeAddress = "0x73af2A6aC50E1f1FF8F9f596a34F4b10047bb0DB";

const lockRewardAddress = "0x59C5F098967351D27B07eDDD0c93DA8Ffec9386e";
const lockTreasuryAddress = "0x271bc8cc0c12808DD3B95a192Db30777Ea4dd689";

const normalRewardAddress = "0x3E222ed9fAd9E7D53354327Ab3912bBb8177d02a";
const normalTreasuryAddress = "0xb84DaE475Fc7c676d2Fd48d2673543A706c13C77";
async function main() {
  let tx;
  const ArborsStaking = await ethers.getContractFactory("ArborsStakingWithDividend");
  const ArborsStakingWithFixedLockTime = await ethers.getContractFactory("ArborsStakingWithDividendAndFixedLockTime");

  const arborsStaking = ArborsStaking.attach(normalStakeAddress);
  const arborsStakingWithFixedLockTime = ArborsStakingWithFixedLockTime.attach(lockStakeAddress);

  console.log("Setting Deposit Wallet for Normal Staking");
  tx = await arborsStaking.setDepositWallet(normalTreasuryAddress);
  await tx.wait();
  console.log("Setting Reward Wallet for Normal Staking");
  tx = await arborsStaking.setRewardWallet(normalRewardAddress);
  await tx.wait();

  console.log("Setting Deposit Wallet for Lock Staking");
  tx = await arborsStakingWithFixedLockTime.setDepositWallet(lockTreasuryAddress);
  await tx.wait();
  console.log("Setting Reward Wallet for Lock Staking");
  tx = await arborsStakingWithFixedLockTime.setRewardWallet(lockRewardAddress);
  await tx.wait();

  console.log("Staking complete setup, just need to fill reward");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
