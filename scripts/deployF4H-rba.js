const {ethers} = require("hardhat");
const hre = require("hardhat");

async function main() {
  this.Token = await ethers.getContractFactory("Fight4Hope");
  this.Dividend = await ethers.getContractFactory("Fight4HopeDividendTracker");

  const marketingWallet = "0x0171cDe0B76aFA40522c54301990043a853BA82D";
  const blackListWallet = "0x0171cDe0B76aFA40522c54301990043a853BA82D";
  const bridgeVault = "0x059f187aFfdcC7f7Cb1149285c3c687A5895b906";
  const buyBackWallet = "0x0171cDe0B76aFA40522c54301990043a853BA82D";
  const rbaToken = "0x238F5666A0f12c571B7B3fBd5b5a434146dFa0C5";
  const router = "0x2fAe743821Bbc2CfD025C7E6B3Ee01ae202dd48B";
  const f4h = "0xFAe063159b4d83d8491271a165eECa5632E4c288";
  const usdc = "0x430EA547076C0051B252b1ab1ef83cd83F2D1aB4";

  // this.token = await this.Token.deploy(router, rbaToken, marketingWallet, bridgeVault);

  // await this.token.deployed();

  this.dividendTracker = await this.Dividend.deploy(rbaToken, f4h);
  await this.dividendTracker.deployed();

  // console.log("Token deployed to:", this.token.address);
  console.log("dividendTracker deployed to:", this.dividendTracker.address);

  // try {
  //   await hre.run("verify", {
  //     address: this.dividendTracker.address,
  //     constructorArgsParams: [rbaToken, this.token.address],
  //   });
  // } catch (error) {
  //   console.error(error);
  //   console.log(`dividendTracker contract at address ${this.dividendTracker.address} is already verified`);
  // }

  //   try {
  //     await hre.run("verify", {
  //       address: this.token.address,
  //       constructorArgsParams: [router, rbaToken, marketingWallet, bridgeVault],
  //     });
  //   } catch (error) {
  //     console.error(error);
  //     console.log(`dividendTracker contract at address ${this.dividendTracker.address} is already verified`);
  //   }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
