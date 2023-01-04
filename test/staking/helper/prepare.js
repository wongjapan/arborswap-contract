const {ethers} = require("hardhat");

async function deployDex(deployer) {
  let pancakeFactoryContract;
  let pancakeRouterContract;
  let wbnbContract;

  const PancakeFactory = await ethers.getContractFactory("PancakeFactory");
  pancakeFactoryContract = await PancakeFactory.deploy(pancakeFeeReceiver.address);
  await pancakeFactoryContract.deployed();

  // deploy WBNB factory first
  const WBNBContract = await ethers.getContractFactory("WBNB");
  wbnbContract = await WBNBContract.deploy();
  await wbnbContract.deployed();

  // deploy Pancake Router first
  const routerContract = await ethers.getContractFactory("PancakeRouter");
  pancakeRouterContract = await routerContract.deploy(pancakeFactoryContract.address, wbnbContract.address);
  await pancakeRouterContract.deployed();
}
