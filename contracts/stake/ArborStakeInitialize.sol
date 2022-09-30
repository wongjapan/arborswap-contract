// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ArborStakeInitialize is Ownable, ReentrancyGuard {
  using SafeERC20 for IERC20Metadata;

  address public immutable ARBOR_STAKE_FACTORY;
  address public rewardWallet;

  // Whether it is initialized
  bool public isInitialized;
  uint256 public accTokenPerShare;
  uint256 public bonusEndBlock;
  uint256 public startBlock;
  uint256 public lastRewardBlock;

  uint256 public rewardPerBlock;

  // The precision factor
  uint256 public PRECISION_FACTOR;

  IERC20Metadata public rewardToken;
  IERC20Metadata public stakedToken;

  IERC20Metadata public dividendToken1;
  IERC20Metadata public dividendToken2;

  uint8 public rewardAPY;

  mapping(address => UserInfo) public userInfo;

  struct UserInfo {
    uint256 amount;
    uint256 startBlock;
    uint256 endTime;
    uint256 rewardDebt;
  }

  event Deposit(address indexed user, uint256 amount);
  event EmergencyWithdraw(address indexed user, uint256 amount);
  event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);
  event NewRewardPerBlock(uint256 rewardPerBlock);
  event RewardsStop(uint256 blockNumber);
  event TokenRecovery(address indexed token, uint256 amount);
  event Withdraw(address indexed user, uint256 amount);

  constructor() {
    ARBOR_STAKE_FACTORY = msg.sender;
  }

  function initialize(
    IERC20Metadata _stakedToken,
    IERC20Metadata _rewardToken,
    uint256 _rewardPerBlock,
    uint256 _startBlock,
    uint256 _bonusEndBlock,
    address _admin
  ) external {
    require(!isInitialized, "Already initialized");
    require(msg.sender == ARBOR_STAKE_FACTORY, "Not factory");

    // Make this contract initialized
    isInitialized = true;

    stakedToken = _stakedToken;
    rewardToken = _rewardToken;
    rewardPerBlock = _rewardPerBlock;
    startBlock = _startBlock;
    bonusEndBlock = _bonusEndBlock;

    uint256 decimalsRewardToken = uint256(rewardToken.decimals());
    require(decimalsRewardToken < 30, "Must be inferior to 30");

    PRECISION_FACTOR = uint256(10**(uint256(30) - decimalsRewardToken));

    // Set the lastRewardBlock as the startBlock
    lastRewardBlock = startBlock;

    // Transfer ownership to the admin address who becomes owner of the contract
    transferOwnership(_admin);
  }

  /*
   * @notice Deposit staked tokens and collect reward tokens (if any)
   * @param _amount: amount to withdraw (in rewardToken)
   */
  function deposit(uint256 _amount) external nonReentrant {
    UserInfo storage user = userInfo[msg.sender];

    _updatePool();

    if (user.amount > 0) {
      uint256 pending = (user.amount * accTokenPerShare) / PRECISION_FACTOR - user.rewardDebt;
      if (pending > 0) {
        rewardToken.safeTransfer(address(msg.sender), pending);
      }
    }

    if (_amount > 0) {
      user.amount = user.amount + _amount;
      stakedToken.safeTransferFrom(address(msg.sender), address(this), _amount);
    }

    user.rewardDebt = (user.amount * accTokenPerShare) / PRECISION_FACTOR;

    emit Deposit(msg.sender, _amount);
  }

  /*
   * @notice Withdraw staked tokens and collect reward tokens
   * @param _amount: amount to withdraw (in rewardToken)
   */
  function withdraw(uint256 _amount) external nonReentrant {
    UserInfo storage user = userInfo[msg.sender];
    require(user.amount >= _amount, "Amount to withdraw too high");

    _updatePool();

    uint256 pending = (user.amount * accTokenPerShare) / PRECISION_FACTOR - user.rewardDebt;

    if (_amount > 0) {
      user.amount = user.amount - _amount;
      stakedToken.safeTransfer(address(msg.sender), _amount);
    }

    if (pending > 0) {
      rewardToken.safeTransfer(address(msg.sender), pending);
    }

    user.rewardDebt = (user.amount * accTokenPerShare) / PRECISION_FACTOR;

    emit Withdraw(msg.sender, _amount);
  }

  /*
   * @notice Withdraw staked tokens without caring about rewards rewards
   * @dev Needs to be for emergency.
   */
  function emergencyWithdraw() external nonReentrant {
    UserInfo storage user = userInfo[msg.sender];
    uint256 amountToTransfer = user.amount;
    user.amount = 0;
    user.rewardDebt = 0;

    if (amountToTransfer > 0) {
      stakedToken.safeTransfer(address(msg.sender), amountToTransfer);
    }

    emit EmergencyWithdraw(msg.sender, user.amount);
  }

  /*
   * @notice Stop rewards
   * @dev Only callable by owner. Needs to be for emergency.
   */
  function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {
    rewardToken.safeTransfer(address(msg.sender), _amount);
  }

  /**
   * @notice Allows the owner to recover tokens sent to the contract by mistake
   * @param _token: token address
   * @dev Callable by owner
   */
  function recoverToken(address _token) external onlyOwner {
    require(_token != address(stakedToken), "Operations: Cannot recover staked token");
    require(_token != address(rewardToken), "Operations: Cannot recover reward token");

    uint256 balance = IERC20Metadata(_token).balanceOf(address(this));
    require(balance != 0, "Operations: Cannot recover zero balance");

    IERC20Metadata(_token).safeTransfer(address(msg.sender), balance);

    emit TokenRecovery(_token, balance);
  }

  /*
   * @notice Stop rewards
   * @dev Only callable by owner
   */
  function stopReward() external onlyOwner {
    bonusEndBlock = block.number;
  }

  /*
   * @notice Update reward per block
   * @dev Only callable by owner.
   * @param _rewardPerBlock: the reward per block
   */
  function updateRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {
    require(block.number < startBlock, "Pool has started");
    rewardPerBlock = _rewardPerBlock;
    emit NewRewardPerBlock(_rewardPerBlock);
  }

  /**
   * @notice It allows the admin to update start and end blocks
   * @dev This function is only callable by owner.
   * @param _startBlock: the new start block
   * @param _bonusEndBlock: the new end block
   */
  function updateStartAndEndBlocks(uint256 _startBlock, uint256 _bonusEndBlock) external onlyOwner {
    require(block.number < startBlock, "Pool has started");
    require(_startBlock < _bonusEndBlock, "New startBlock must be lower than new endBlock");
    require(block.number < _startBlock, "New startBlock must be higher than current block");

    startBlock = _startBlock;
    bonusEndBlock = _bonusEndBlock;

    // Set the lastRewardBlock as the startBlock
    lastRewardBlock = startBlock;

    emit NewStartAndEndBlocks(_startBlock, _bonusEndBlock);
  }

  /*
   * @notice View function to see pending reward on frontend.
   * @param _user: user address
   * @return Pending reward for a given user
   */
  function pendingReward(address _user) external view returns (uint256) {
    UserInfo storage user = userInfo[_user];
    uint256 stakedTokenSupply = stakedToken.balanceOf(address(this));
    if (block.number > lastRewardBlock && stakedTokenSupply != 0) {
      uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
      uint256 tokenReward = multiplier * rewardPerBlock;
      uint256 adjustedTokenPerShare = accTokenPerShare + (tokenReward * PRECISION_FACTOR) / stakedTokenSupply;
      return (user.amount * adjustedTokenPerShare) / PRECISION_FACTOR - user.rewardDebt;
    } else {
      return (user.amount * accTokenPerShare) / PRECISION_FACTOR - user.rewardDebt;
    }
  }

  /*
   * @notice Update reward variables of the given pool to be up-to-date.
   */
  function _updatePool() internal {
    if (block.number <= lastRewardBlock) {
      return;
    }

    uint256 stakedTokenSupply = stakedToken.balanceOf(address(this));

    if (stakedTokenSupply == 0) {
      lastRewardBlock = block.number;
      return;
    }

    uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);
    uint256 tokenReward = multiplier * rewardPerBlock;
    accTokenPerShare = accTokenPerShare + (tokenReward * PRECISION_FACTOR) / stakedTokenSupply;
    lastRewardBlock = block.number;
  }

  /*
   * @notice Return reward multiplier over the given _from to _to block.
   * @param _from: block to start
   * @param _to: block to finish
   */
  function _getMultiplier(uint256 _from, uint256 _to) internal view returns (uint256) {
    if (_to <= bonusEndBlock) {
      return _to - _from;
    } else if (_from >= bonusEndBlock) {
      return 0;
    } else {
      return bonusEndBlock - _from;
    }
  }
}
