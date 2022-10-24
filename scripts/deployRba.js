const {ethers} = require("hardhat");
const hre = require("hardhat");

async function main() {
  this.Token = await ethers.getContractFactory("Roburna");
  this.Dividend = await ethers.getContractFactory("RoburnaDividendTracker");

  const marketingWallet = "0x059f187aFfdcC7f7Cb1149285c3c687A5895b906";
  const blackListWallet = "0xC6d96E8792db0e8aF14C112cA3239d9FAD70aa98";
  const bridgeVault = "0x059f187aFfdcC7f7Cb1149285c3c687A5895b906";
  const buyBackWallet = "0x059f187aFfdcC7f7Cb1149285c3c687A5895b906";
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
