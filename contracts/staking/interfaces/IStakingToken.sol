// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IStakingToken is IERC20 {
  function dividendToken() external view returns (address);

  function withdrawReward(address receiver, uint256 amount) external;
}
