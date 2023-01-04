const hre = require("hardhat");
const {ethers} = require("hardhat");
// const {REWARD_WALLET, TREASURY} = require("./constants/address");

const admin_adress = ["0x9224513121f576441DD9De66d4E598aAD2B433A9"];

async function main() {
  const AdminContract = await ethers.getContractFactory("Admin");
  const FactoryContract = await ethers.getContractFactory("LockFactory");
  const TokenContract = await ethers.getContractFactory("TokenLock");
  const LiquidityContract = await ethers.getContractFactory("LiquidityLock");
  const VestedContract = await ethers.getContractFactory("VestingLock");

  const admin = await AdminContract.deploy(admin_adress);
  await admin.deployed();

  console.log("Admin Contract deployed to:", admin.address);
  //   try {
  //     await hre.run("verify", {
  //       address: admin.address,
  //       constructorArgsParams: [admin_adress],
  //     });
  //   } catch (error) {
  //     console.error(error);
  //     console.log(`Smart contract at address ${admin.address} is already verified`);
  //   }

  const factory = await FactoryContract.deploy(admin.address);
  await factory.deployed();
  console.log("Lock Factory Contract deployed to:", factory.address);

  const tx = await factory.setNormalFee("10000000000000000");
  await tx.wait();
  const tx1 = await factory.setLiquidityFee("10000000000000000");
  tx1.wait();
  //   try {
  //     await hre.run("verify", {
  //       address: factory.address,
  //       constructorArgsParams: [admin.address],
  //     });
  //   } catch (error) {
  //     console.error(error);
  //     console.log(`Smart contract at address ${factory.address} is already verified`);
  //   }

  //   const token_params = [
  //     "0x9224513121f576441DD9De66d4E598aAD2B433A9",
  //     "1681216826",
  //     "1681216826",
  //     "0x7A8Ef598789D23f923b60Dfd8d6C9Fd8F54629DE",
  //     factory.address,
  //     "https://testnet.bscscan.com/images/logo-bscscan.svg?v=0.0.3",
  //   ];

  //   const vested_params = [
  //     "0x9224513121f576441DD9De66d4E598aAD2B433A9",
  //     "1681216826",
  //     "1681216826",
  //     "0x7A8Ef598789D23f923b60Dfd8d6C9Fd8F54629DE",
  //     factory.address,
  //     "50",
  //     "5000",
  //     "10",
  //     "https://testnet.bscscan.com/images/logo-bscscan.svg?v=0.0.3",
  //   ];

  //   const liquidity_params = [
  //     "0x9224513121f576441DD9De66d4E598aAD2B433A9",
  //     "1681216826",
  //     "1681216826",
  //     "0x0290715378ce3079b3525bD35a442b4084397a20",
  //     factory.address,
  //     "https://testnet.bscscan.com/images/logo-bscscan.svg?v=0.0.3",
  //   ];

  //   const token = await TokenContract.deploy(...token_params);
  //   await token.deployed();
  //   console.log("Token Lock Contract deployed to:", token.address);

  //   try {
  //     await hre.run("verify", {
  //       address: token.address,
  //       constructorArgsParams: token_params,
  //     });
  //   } catch (error) {
  //     console.error(error);
  //     console.log(`Smart contract at address ${token.address} is already verified`);
  //   }

  //   const liquidity = await LiquidityContract.deploy(...liquidity_params);
  //   await liquidity.deployed();
  //   console.log("Liquidity Lock Contract deployed to:", liquidity.address);

  //   try {
  //     await hre.run("verify", {
  //       address: liquidity.address,
  //       constructorArgsParams: liquidity_params,
  //     });
  //   } catch (error) {
  //     console.error(error);
  //     console.log(`Smart contract at address ${liquidity.address} is already verified`);
  //   }

  //   const vested = await VestedContract.deploy(...vested_params);
  //   await vested.deployed();
  //   console.log("Vested Lock Contract deployed to:", vested.address);

  //   try {
  //     await hre.run("verify", {
  //       address: vested.address,
  //       constructorArgsParams: vested_params,
  //     });
  //   } catch (error) {
  //     console.error(error);
  //     console.log(`Smart contract at address ${vested.address} is already verified`);
  //   }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
