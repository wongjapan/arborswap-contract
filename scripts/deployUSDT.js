const {ethers} = require("hardhat");
const hre = require("hardhat");

async function main() {
  this.Token = await ethers.getContractFactory("FACTORY");
  this.token = await this.Token.deploy();

  await this.token.deployed();

  //   this.token.

  console.log("Token deployed to:", this.token.address);

  //   try {
  //     await hre.run("verify", {
  //       address: this.dividendTracker.address,
  //       constructorArgsParams: [rbaToken, this.token.address],
  //     });
  //   } catch (error) {
  //     console.error(error);
  //     console.log(`dividendTracker contract at address ${this.dividendTracker.address} is already verified`);
  //   }

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
