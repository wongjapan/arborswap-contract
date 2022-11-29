const hre = require("hardhat");
const {ethers} = require("hardhat");

const ROUTER = "0x2fAe743821Bbc2CfD025C7E6B3Ee01ae202dd48B";
const F4H = "0xFAe063159b4d83d8491271a165eECa5632E4c288";
const DIVTRACKER = "0xcdD7622F623f81966a90e6b310154893952a14cf";
const NEWDIVTRACKER = "0xC77586c3A9d259Ad8D44Fd620C1743Add899e544";
const STAKING = "0x35D830500c217AD19ab24Ad3D08A06B6F88cC061";
const LOCKSTAKING = "0x907be116635eF8F3F360f74A46c10F81434B6908";

const STAKING_DEPOSIT = "0xe4A76f52257d8014dc5CCEC201e944940559554E";
const STAKING_REWARD = "0xdf7cdaC24B72D8Abeb5A8BBb778bBA6eDDF104c7";
const LOCK_STAKING_DEPOSIT = "0xf5488d305F872d9de4F10Ff2f26437873D0c7993";
const LOCK_STAKING_REWARD = "0xd1c919761C8A0FAe9947979B543eD9281Db7f31D";

const AMOUNT = "100000000000000000000000";
const USDC = "0x430EA547076C0051B252b1ab1ef83cd83F2D1aB4";

async function main() {
  const Token = await ethers.getContractFactory("Fight4Hope");
  // const Token = await ethers.getContractFactory("Fight4HopeDividendTracker");
  //   const Token = await ethers.getContractFactory("ArborsStakingWithDividendAndFixedLockTime");
  //   const token = await Token.attach(LOCKSTAKING);
  // const token = await Token.attach(DIVTRACKER);
  const token = await Token.attach(F4H);

  const dex = await token.updateDividendToken(USDC, NEWDIVTRACKER);
  // const dex = await token.automatedMarketMakerPairs("0xd57381b6481f6cad992e65df54a7e75d99bfa73d");
  console.log(dex);
  //   await token.setRewardWallet(LOCK_STAKING_REWARD);

  // const divAddr = await token.dividendTracker();

  // console.log("token name:", divAddr);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
