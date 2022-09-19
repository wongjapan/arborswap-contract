const data = require("./constants/data.json");

const compiled =
  data.output.contracts["contracts/exchange-protocol/ArborSwapFactory.sol"].ArborSwapFactory.evm.deployedBytecode
    .object;

console.log(compiled);
