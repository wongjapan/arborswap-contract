const {ethers} = require("hardhat");
const hre = require("hardhat");

async function main() {
  this.Token = await ethers.getContractFactory("Fight4Hope");
  this.Dividend = await ethers.getContractFactory("Fight4HopeDividendTracker");

  const marketingWallet = "0x0171cDe0B76aFA40522c54301990043a853BA82D";
  const blackListWallet = "0x0171cDe0B76aFA40522c54301990043a853BA82D";
  const bridgeVault = "0x059f187aFfdcC7f7Cb1149285c3c687A5895b906";
  const buyBackWallet = "0x0171cDe0B76aFA40522c54301990043a853BA82D";
  const rbaToken = "0xb89f9A34eF21ea8cc0475EdA7542A61E9C7108A9";
  const router = "0x4e1845Ab1d9D464150777a931Ce8FDaaD1cf8229";

  this.token = await this.Token.deploy(router, rbaToken, marketingWallet, bridgeVault);

  await this.token.deployed();

  this.dividendTracker = await this.Dividend.deploy(rbaToken, this.token.address);
  await this.dividendTracker.deployed();

  console.log("Token deployed to:", this.token.address);
  console.log("dividendTracker deployed to:", this.dividendTracker.address);

  try {
    await hre.run("verify", {
      address: this.dividendTracker.address,
      constructorArgsParams: [rbaToken, this.token.address],
    });
  } catch (error) {
    console.error(error);
    console.log(`dividendTracker contract at address ${this.dividendTracker.address} is already verified`);
  }

  try {
    await hre.run("verify", {
      address: this.token.address,
      constructorArgsParams: [router, rbaToken, marketingWallet, bridgeVault],
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
