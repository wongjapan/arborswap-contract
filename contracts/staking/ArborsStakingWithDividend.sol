// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IStakingWallet.sol";

contract ArborsStakingWithDividend is Ownable, Pausable, ReentrancyGuard {
  struct StakerInfo {
    uint256 amount;
    uint256 startTime;
    uint256 stakeRewards;
  }

  struct Info {
    uint256 totalStaked;
    uint256 totalRewardDepositted;
    uint256 totalRewardWithdrawn;
    uint256 activeStaker;
    uint256 totalStaker;
  }

  Info public platformInfo;

  // Staker Info
  mapping(address => StakerInfo) public staker;

  uint256 public constant YEAR_SECOND = 31577600;

  uint256 public immutable rate;

  IERC20 public immutable stakeToken;
  IERC20 public immutable rewardsToken;

  IStakingWallet public rewardWallet;
  IStakingWallet public depositWallet;

  event LogStake(address indexed from, uint256 amount);
  event LogUnstake(address indexed from, uint256 amount, uint256 amountRewards);
  event LogRewardsWithdrawal(address indexed to, uint256 amount);
  event LogTokenRecovery(address tokenRecovered, uint256 amount);
  event LogChangeRewardWallet(IStakingWallet _old, IStakingWallet _new);
  event LogChangeDepositWallet(IStakingWallet _old, IStakingWallet _new);
  event LogFillReward(address filler, uint256 amount);

  constructor(
    IERC20 _stakeToken,
    IERC20 _rewardsToken,
    uint256 _rate
  ) {
    stakeToken = _stakeToken;
    rewardsToken = _rewardsToken;
    rate = _rate;
  }

  function setRewardWallet(IStakingWallet _addr) external onlyOwner {
    emit LogChangeRewardWallet(rewardWallet, _addr);
    rewardWallet = _addr;
  }

  function setDepositWallet(IStakingWallet _addr) external onlyOwner {
    emit LogChangeDepositWallet(depositWallet, _addr);
    depositWallet = _addr;
  }

  function stake(uint256 _amount) external whenNotPaused {
    require(address(rewardWallet) != address(0), "Reward Wallet not Set");
    require(address(depositWallet) != address(0), "Deposit Wallet not Set");

    require(_amount > 0, "Staking amount must be greater than zero");
    require(stakeToken.allowance(msg.sender, address(this)) >= _amount, "Insufficient allowance.");

    require(stakeToken.balanceOf(msg.sender) >= _amount, "Insufficient stakeToken balance");

    if (staker[msg.sender].amount > 0) {
      staker[msg.sender].stakeRewards = getTotalRewards(msg.sender);
    } else {
      platformInfo.totalStaker = platformInfo.totalStaker + 1;
      platformInfo.activeStaker = platformInfo.activeStaker + 1;
    }

    stakeToken.transferFrom(msg.sender, address(depositWallet), _amount);

    staker[msg.sender].amount += _amount;
    staker[msg.sender].startTime = block.timestamp;

    platformInfo.totalStaked = platformInfo.totalStaked + _amount;

    emit LogStake(msg.sender, _amount);
  }

  function unstake(uint256 _amount) external whenNotPaused nonReentrant {
    require(_amount > 0, "Unstaking amount must be greater than zero");
    require(staker[msg.sender].amount >= _amount, "Insufficient unstake");

    uint256 amountWithdraw = _withdrawRewards();
    staker[msg.sender].amount -= _amount;
    staker[msg.sender].startTime = block.timestamp;
    staker[msg.sender].stakeRewards = 0;

    platformInfo.totalStaked = platformInfo.totalStaked - _amount;
    platformInfo.totalRewardWithdrawn = platformInfo.totalRewardWithdrawn + amountWithdraw;
    platformInfo.activeStaker = platformInfo.activeStaker - 1;

    depositWallet.withdrawReward(msg.sender, _amount);

    emit LogUnstake(msg.sender, _amount, amountWithdraw);
  }

  function fillRewards(uint256 _amount) external whenNotPaused {
    require(address(rewardWallet) != address(0), "Reward Wallet not Set");
    require(_amount > 0, "reward amount must be greater than zero");
    require(rewardsToken.balanceOf(msg.sender) >= _amount, "Insufficient rewardsToken balance");
    require(rewardsToken.transferFrom(msg.sender, address(rewardWallet), _amount), "TransferFrom fail");

    platformInfo.totalRewardDepositted = platformInfo.totalRewardDepositted + _amount;
    emit LogFillReward(msg.sender, _amount);
  }

  function _withdrawRewards() internal returns (uint256) {
    uint256 amountWithdraw = getTotalRewards(msg.sender);
    if (amountWithdraw > 0) {
      rewardWallet.withdrawReward(msg.sender, amountWithdraw);
    }
    return amountWithdraw;
  }

  function withdrawRewards() external whenNotPaused nonReentrant {
    uint256 amountWithdraw = _withdrawRewards();
    require(amountWithdraw > 0, "Insufficient rewards balance");
    staker[msg.sender].startTime = block.timestamp;
    staker[msg.sender].stakeRewards = 0;

    emit LogRewardsWithdrawal(msg.sender, amountWithdraw);
  }

  function getTotalRewards(address _staker) public view returns (uint256) {
    uint256 newRewards = ((block.timestamp - staker[_staker].startTime) * staker[_staker].amount * rate) /
      (YEAR_SECOND * 100);
    return newRewards + staker[_staker].stakeRewards;
  }

  function calculateRewards(uint256 _start, uint256 _amount) public view returns (uint256) {
    uint256 newRewards = ((block.timestamp - _start) * _amount * rate) / (YEAR_SECOND * 100);
    return newRewards;
  }

  function calculateDayRewards(uint256 _start, uint256 _amount) public view returns (uint256) {
    uint256 newRewards = ((_start * 1 days) * _amount * rate) / (YEAR_SECOND * 100);
    return newRewards;
  }

  function getPendingRewards(address _staker) public view returns (uint256) {
    return staker[_staker].stakeRewards;
  }

  function setPause() external onlyOwner {
    _pause();
  }

  function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {
    require(_tokenAddress != address(stakeToken), "Cannot be staked token");
    require(_tokenAddress != address(rewardsToken), "Cannot be reward token");

    IERC20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);

    emit LogTokenRecovery(_tokenAddress, _tokenAmount);
  }

  function setUnpause() external onlyOwner {
    _unpause();
  }
}
