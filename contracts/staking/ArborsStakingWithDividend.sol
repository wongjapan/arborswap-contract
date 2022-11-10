// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract ArborsStakingWithDividend is Ownable, Pausable {
  struct StakerInfo {
    uint256 amount;
    uint256 startTime;
    uint256 stakeRewards;
  }

  // Staker Info
  mapping(address => StakerInfo) public staker;

  uint256 public constant YEAR_SECOND = 31577600;

  uint256 public rate;

  IERC20 public immutable stakeToken;
  IERC20 public immutable rewardsToken;

  event LogStake(address indexed from, uint256 amount);
  event LogUnstake(address indexed from, uint256 amount, uint256 amountRewards);
  event LogRewardsWithdrawal(address indexed to, uint256 amount);
  event LogSetRate(uint256 rate);
  event LogTokenRecovery(address tokenRecovered, uint256 amount);

  constructor(
    IERC20 _stakeToken,
    IERC20 _rewardsToken,
    uint256 _rate
  ) {
    stakeToken = _stakeToken;
    rewardsToken = _rewardsToken;
    rate = _rate;
  }

  function stake(uint256 _amount) external whenNotPaused {
    require(_amount > 0, "Staking amount must be greater than zero");

    require(stakeToken.balanceOf(msg.sender) >= _amount, "Insufficient stakeToken balance");

    if (staker[msg.sender].amount > 0) {
      staker[msg.sender].stakeRewards = getTotalRewards(msg.sender);
    }

    require(stakeToken.transferFrom(msg.sender, address(this), _amount), "TransferFrom fail");

    staker[msg.sender].amount += _amount;
    staker[msg.sender].startTime = block.timestamp;
    emit LogStake(msg.sender, _amount);
  }

  function unstake(uint256 _amount) external whenNotPaused {
    require(_amount > 0, "Unstaking amount must be greater than zero");
    require(staker[msg.sender].amount >= _amount, "Insufficient unstake");

    uint256 amountWithdraw = _withdrawRewards();
    staker[msg.sender].amount -= _amount;
    staker[msg.sender].startTime = block.timestamp;
    staker[msg.sender].stakeRewards = 0;

    require(stakeToken.transfer(msg.sender, _amount), "TransferFrom fail");

    emit LogUnstake(msg.sender, _amount, amountWithdraw);
  }

  function _withdrawRewards() internal returns (uint256) {
    uint256 amountWithdraw = getTotalRewards(msg.sender);
    if (amountWithdraw > 0) {
      require(rewardsToken.transfer(msg.sender, amountWithdraw), "TransferFrom fail");
    }
    return amountWithdraw;
  }

  function withdrawRewards() external whenNotPaused {
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

  function setRate(uint256 _rate) external onlyOwner {
    rate = _rate;
    emit LogSetRate(rate);
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