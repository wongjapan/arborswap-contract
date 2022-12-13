const {ethers} = require("hardhat");
const hre = require("hardhat");

const dexABI = require("./abi/dex.json");
const ercABI = require("./abi/erc.json");

async function addFunds() {
  const daiAddress = "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56";
  const accountToImpersonate = "0xbCD93566Ee5C12ab20A01cdD26C68b55EEFBAC61";
  const accountToFund = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
  const amountToMove = "50000000000000000000000"; // 50,000 DAI

  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [accountToImpersonate],
  });

  const signer = await ethers.provider.getSigner(accountToImpersonate);
  const daiContract = new ethers.Contract(daiAddress, ercABI, signer);

  const accountBalanceWhale = await daiContract.balanceOf(accountToImpersonate);
  console.log("whale dai account balance:", accountBalanceWhale / 1e18);

  console.log("transfering to", accountToFund);
  await daiContract.connect(signer).transfer(accountToFund, amountToMove);
  const accountBalance = await daiContract.balanceOf(accountToFund);
  console.log("funded account balance", accountBalance / 1e18);

  const whaleBalanceAfter = await daiContract.balanceOf(accountToImpersonate);
  console.log("whale dai balance after", whaleBalanceAfter / 1e18);
}

async function main() {
  await addFunds();
}

main();
