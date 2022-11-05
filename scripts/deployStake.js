const hre = require("hardhat");
const {ethers} = require("hardhat");

const stakeToken = "0x083295D160A243D0A850Bc75E317e1c56f935EA9";
const rewardToken = "0x083295D160A243D0A850Bc75E317e1c56f935EA9";
const rate = "5";

async function main() {
  const ArborsStaking = await ethers.getContractFactory("ArborsStaking");
  const arborsStaking = await ArborsStaking.deploy(stakeToken, rewardToken, rate);

  await arborsStaking.deployed();

  console.log("ArborsStaking deployed to:", arborsStaking.address);

  try {
    await hre.run("verify", {
      address: arborsStaking.address,
      constructorArgsParams: [stakeToken, rewardToken, rate],
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
