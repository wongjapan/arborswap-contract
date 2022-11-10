const {ethers} = require("hardhat");
const hre = require("hardhat");

async function main() {
  this.Token = await ethers.getContractFactory("Roburna");
  this.Dividend = await ethers.getContractFactory("RoburnaDividendTracker");

  const marketingWallet = "0x33d3fCbEe14FE85627F5Ca3A5F80fCaD30205108";
  const blackListWallet = "0x4c0364A791Ed5cA5898a9B7C07800B542816C0A8";
  const bridgeVault = "0x059f187aFfdcC7f7Cb1149285c3c687A5895b906";
  const buyBackWallet = "0x0171cDe0B76aFA40522c54301990043a853BA82D";
  const usdc = "0x7ef95a0fee0dd31b22626fa2e10ee6a223f8a684";
  const router = "0x4e1845Ab1d9D464150777a931Ce8FDaaD1cf8229";

  this.token = await this.Token.deploy(router, usdc, marketingWallet, buyBackWallet, blackListWallet, bridgeVault);

  await this.token.deployed();

  this.dividendTracker = await this.Dividend.deploy(usdc, this.token.address);
  await this.dividendTracker.deployed();

  console.log("Token deployed to:", this.token.address);
  console.log("dividendTracker deployed to:", this.dividendTracker.address);

  try {
    await hre.run("verify", {
      address: this.dividendTracker.address,
      constructorArgsParams: [usdc, this.token.address],
    });
  } catch (error) {
    console.error(error);
    console.log(`dividendTracker contract at address ${this.dividendTracker.address} is already verified`);
  }

  try {
    await hre.run("verify", {
      address: this.token.address,
      constructorArgsParams: [router, usdc, marketingWallet, buyBackWallet, blackListWallet, bridgeVault],
    });
  } catch (error) {
    console.error(error);
    console.log(`dividendTracker contract at address ${this.dividendTracker.address} is already verified`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
