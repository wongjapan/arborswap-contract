const hre = require("hardhat");

async function main() {
  const _marketingWallet = "0x1547b436463650d5083ecf90D55Acc35fbd58fe4";
  const _teamWallet = "0xE63d424631bdACa918DC96D67c4Be12Bfd771CF6";
  const _router = "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3";

  const EmpireBridgeVault = await ethers.getContractFactory("EmpireBridgeVault");
  const bridgeVault = await EmpireBridgeVault.deploy();
  await bridgeVault.deployed();
  console.log("Bridge Vault deployed to:", bridgeVault.address);

  // We get the contract to deploy
  const EmpireToken = await ethers.getContractFactory("EmpireToken");
  const empire = await EmpireToken.deploy(_router, _marketingWallet, _teamWallet, bridgeVault.address);

  await empire.deployed();

  console.log("EmpireToken deployed to:", empire.address);

  try {
    await hre.run("verify", {
      address: empire.address,
      constructorArgsParams: [_router, _marketingWallet, _teamWallet, bridgeVault.address],
    });
  } catch (error) {
    console.error(error);
    console.log(`Smart contract at address ${bridge.address} is already verified`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
