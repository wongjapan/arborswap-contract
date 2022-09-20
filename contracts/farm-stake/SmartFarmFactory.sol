// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import "./SmartFarm.sol";

contract SmartFarmFactory is Ownable {
  event NewSmartFarmContract(address indexed smartFarm);

  constructor() public {
    //
  }

  /*
   * @notice Deploy the pool
   * @param _stakedToken: staked token address
   * @param _rewardToken: reward token address
   * @param _rewardPerBlock: reward per block (in rewardToken)
   * @param _startBlock: start block
   * @param _endBlock: end block
   * @param _poolLimitPerUser: pool limit per user in stakedToken (if any, else 0)
   * @param _admin: admin address with ownership
   * @return address of new smart chef contract
   */
  function deployPool(
    IERC20Metadata _stakedToken,
    IERC20Metadata _rewardToken,
    uint256 _rewardPerBlock,
    uint256 _startBlock,
    uint256 _bonusEndBlock,
    uint256 _poolLimitPerUser,
    address _admin
  ) external onlyOwner {
    require(_stakedToken.totalSupply() >= 0);
    require(_rewardToken.totalSupply() >= 0);
    require(_stakedToken != _rewardToken, "Tokens must be be different");

    bytes memory bytecode = type(SmartFarm).creationCode;
    bytes32 salt = keccak256(abi.encodePacked(_stakedToken, _rewardToken, _startBlock));
    address smartFarmAddress;

    assembly {
      smartFarmAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
    }

    SmartFarm(smartFarmAddress).initialize(
      _stakedToken,
      _rewardToken,
      _rewardPerBlock,
      _startBlock,
      _bonusEndBlock,
      _poolLimitPerUser,
      _admin
    );

    emit NewSmartFarmContract(smartFarmAddress);
  }
}
