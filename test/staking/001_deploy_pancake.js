const {expect} = require("chai");
const {ethers} = require("hardhat");

describe("Staking Test", function () {
  let deployer;
  let pancakeFeeReceiver;
  let client1;
  let client2;
  let client3;
  let client4;
  let client5;
  let client6;
  let client7;
  let client8;
  let client9;
  let client10;
  let addrs;

  before(async function () {
    // get signers
    [
      deployer,
      pancakeFeeReceiver,
      client1,
      client2,
      client3,
      client4,
      client5,
      client6,
      client7,
      client8,
      client9,
      client10,
      ...addrs
    ] = await ethers.getSigners();

    // deploy pancake factory first
  });

  it("Get INIT_CODE_PAIR_HASH", async function () {});
});
