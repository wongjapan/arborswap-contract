const hre = require("hardhat");
const {ethers} = require("hardhat");

const ADDRESS = "0x2B6f0c2Acb35fD622cC9965A1f706F327c16a29a";
// const REC = "0xE1744115af325c2E889b1B5Ed565c1F30687074A";
const REC = "0x9103C517696422FC0F0e5DEc285330fF063F1D49";

async function main() {
  const Token = await ethers.getContractFactory("MYTEST1155");
  const token = await Token.attach(ADDRESS);

  await token.mint(REC, 0, 100, "");
  //   await token.setRewardWallet(LOCK_STAKING_REWARD);

  //   const divAddr = await token.dividendTracker();

  //   console.log("token name:", divAddr);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
