const {parseEther, parseUnits} = require("ethers/lib/utils");
const hre = require("hardhat");
const {ethers} = require("hardhat");
const {faker} = require("@faker-js/faker");
const fs = require("fs");
const rec = "0x9224513121f576441DD9De66d4E598aAD2B433A9";
const routerAddress = "0x59384a06c86531aF46662845cdD4086F538E7eeA";
const wbnb = "0x238F5666A0f12c571B7B3fBd5b5a434146dFa0C5";
const INITIAL_LIQUIDITY = parseUnits("100", 18);
const INITIAL_BNB_LIQUIDITY = parseUnits("1", 18);
const TOTAL_SUPPLY = parseUnits("5000000000", 18);

// Will you please ask your Dev team to put a presale on for me.

// 5b supply

// 3 million per Rba

// Hc 350

// Sc 250

async function main() {
  const _name = faker.name.firstName();
  const name = `${_name} Token`;
  const symbol = faker.random.alpha({count: 3, casing: "upper"});

  const SaleToken = await ethers.getContractFactory("MockToken");
  const saleContract = await SaleToken.deploy(name, symbol, rec, TOTAL_SUPPLY.toString());

  await saleContract.deployed();
  const data = `
Token Name      : ${name}
Token Symbol    : ${symbol}
Token Address   : ${saleContract.address}
=============================================
`;
  fs.appendFileSync("mockAddress.txt", data);
  console.log(data);

  try {
    await hre.run("verify", {
      address: saleContract.address,
      constructorArgsParams: [name, symbol, rec, TOTAL_SUPPLY.toString()],
    });
  } catch (error) {
    console.error(error);
    console.log(`Smart contract at address ${saleContract.address} is already verified`);
  }

  // await bnbToken.approve(routerAddress, ethers.constants.MaxUint256);
  // await saleContract.approve(routerAddress, ethers.constants.MaxUint256);

  // const liq = await routerToken.addLiquidityETH(
  //   saleContract.address,
  //   INITIAL_LIQUIDITY,
  //   0,
  //   0,
  //   rec,
  //   Math.floor(Date.now() / 1000) + 60 * 10,
  //   {value: INITIAL_BNB_LIQUIDITY}
  // );
  // liq.wait();
  // console.log(liq);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
