const hre = require("hardhat");
const {ethers} = require("hardhat");

const normalStakeAddress = "0xDd9a1ACE63E912239F325122d677D18D930333f6";
const lockStakeAddress = "0xA1D6DE0a9771066bDa7e29c8B7c2c302Bc557313";

const lockRewardAddress = "0xe14409c3673f5F4797b2F93005B90f57f7b5225C";
const lockTreasuryAddress = "0xeFf860191F55a1cd6b8617DC2B7bb7b1342a18d7";

const normalRewardAddress = "0xFe3902073E03D88f97A1C34277Eec02bf7cE6E12";
const normalTreasuryAddress = "0x4104E9DA68208FC084371957555A59dAEf518426";

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
