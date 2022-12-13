const hre = require("hardhat");
const {ethers} = require("hardhat");

const mainToken = "0xa5F8128d04692656a60f17B349C2146c48e6863a";
const stakingContract = "0xA1D6DE0a9771066bDa7e29c8B7c2c302Bc557313";

async function main() {
  const ArborStakingWallet = await ethers.getContractFactory("ArborStakingWallet");
  const arborsStakingWallet = await ArborStakingWallet.deploy(mainToken, stakingContract);

  await arborsStakingWallet.deployed();

  const arborsStakingWallet2 = await ArborStakingWallet.deploy(mainToken, stakingContract);
  await arborsStakingWallet2.deployed();

  console.log("RewardWallet deployed to:", arborsStakingWallet.address);
  console.log("TreasuryWallet deployed to:", arborsStakingWallet2.address);

  try {
    await hre.run("verify", {
      address: arborsStakingWallet.address,
      constructorArgsParams: [mainToken, stakingContract],
    });
    await hre.run("verify", {
      address: arborsStakingWallet2.address,
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
