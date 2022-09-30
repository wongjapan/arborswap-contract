// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "bsc-library/contracts/IBEP20.sol";

import "./SmartChefInitializable.sol";

contract SmartChefFactory is Ownable {
  event NewSmartChefContract(address indexed smartChef);

  constructor() public {
    //
  }

  function deployPool(
    IBEP20 _stakedToken,
    IBEP20 _rewardToken,
    uint256 _rewardPerBlock,
    uint256 _startBlock,
    uint256 _bonusEndBlock,
    uint256 _poolLimitPerUser,
    address _admin
  ) external onlyOwner {
    require(_stakedToken.totalSupply() >= 0);
    require(_rewardToken.totalSupply() >= 0);
    require(_stakedToken != _rewardToken, "Tokens must be be different");

    bytes memory bytecode = type(SmartChefInitializable).creationCode;
    bytes32 salt = keccak256(abi.encodePacked(_stakedToken, _rewardToken, _startBlock));
    address smartChefAddress;

    assembly {
      smartChefAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
    }

    SmartChefInitializable(smartChefAddress).initialize(
      _stakedToken,
      _rewardToken,
      _rewardPerBlock,
      _startBlock,
      _bonusEndBlock,
      _poolLimitPerUser,
      _admin
    );

    emit NewSmartChefContract(smartChefAddress);
  }
}
