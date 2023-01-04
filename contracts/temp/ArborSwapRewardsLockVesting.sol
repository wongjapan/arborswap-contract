// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract ArborSwapRewardsLockVesting {
  using SafeMath for *;

  uint256 public totalTokensWithdrawn;

  uint256 public TGEPortion;
  uint256 public vestedLockedAmount;
  uint256 public amountPerPortion;
  bool public TGEPortionWithdrawn;
  bool[] public isVestedPortionWithdrawn;
  bool public allTokensWithdrawn;
  bool public tokensLocked;
  IERC20 public dividendToken;

  address public factory;
  IERC20 public token;

  address public owner;

  uint256 public TGEPortionUnlockingTime;
  uint256 public numberOfPortions;
  uint256[] distributionDates;

  event LogLock(address owner, uint256 amount);
  event LogWithdrawReflections(address owner, uint256 reflections);
  event LogWithdrawDividends(address owner, uint256 dividends);

  modifier onlyOwner() {
    require(msg.sender == owner, "OnlyOwner: Restricted access.");
    _;
  }

  modifier onlyOwnerOrFactory() {
    require(msg.sender == owner || msg.sender == factory, "OnlyOwnerOrFactory: Restricted access.");
    _;
  }

  /// Load initial distribution dates Vesting
  constructor(
    uint256 _numberOfPortions,
    uint256 timeBetweenPortions,
    uint256 distributionStartDate,
    uint256 _TGEPortionUnlockingTime,
    address _owner,
    address _token,
    address _factory
  ) {
    require(_owner != address(0), "Invalid owner address");
    require(_token != address(0), "Invalid token address");

    owner = _owner;
    // Store number of portions
    numberOfPortions = _numberOfPortions;
    factory = _factory;

    // Time when initial portion is unlocked
    TGEPortionUnlockingTime = _TGEPortionUnlockingTime;

    // Set distribution dates
    for (uint256 i = 0; i < _numberOfPortions; i++) {
      distributionDates.push(distributionStartDate + i * timeBetweenPortions);
    }
    // Set the token address
    token = IERC20(_token);
  }

  /// Register participant
  function lock(uint256 amount, uint256 tgePortionPercent) external payable onlyOwnerOrFactory {
    require(!tokensLocked, "Tokens already locked.");

    uint256 TGEPortionAmount = amount.mul(tgePortionPercent).div(100);

    uint256 vestedAmount = amount.sub(TGEPortionAmount);

    // Compute amount per portion
    uint256 portionAmount = vestedAmount.div(numberOfPortions);
    bool[] memory isPortionWithdrawn = new bool[](numberOfPortions);

    TGEPortion = TGEPortionAmount;
    vestedLockedAmount = vestedAmount;
    amountPerPortion = portionAmount;
    TGEPortionWithdrawn = false;
    isVestedPortionWithdrawn = isPortionWithdrawn;

    tokensLocked = true;

    emit LogLock(owner, amount);
  }

  // User will always withdraw everything available
  function withdraw() external onlyOwner {
    address user = msg.sender;
    require(tokensLocked == true, "Withdraw: Tokens were not locked.");

    uint256 totalToWithdraw = 0;

    // Initial portion can be withdrawn
    if (!TGEPortionWithdrawn && block.timestamp >= TGEPortionUnlockingTime) {
      totalToWithdraw = totalToWithdraw.add(TGEPortion);
      // Mark initial portion as withdrawn
      TGEPortionWithdrawn = true;
    }

    // For loop instead of while
    for (uint256 i = 0; i < numberOfPortions; i++) {
      if (isPortionUnlocked(i) == true && i < distributionDates.length) {
        if (!isVestedPortionWithdrawn[i]) {
          // Add this portion to withdraw amount
          totalToWithdraw = totalToWithdraw.add(amountPerPortion);

          // Mark portion as withdrawn
          isVestedPortionWithdrawn[i] = true;
        }
      }
    }

    // Account total tokens withdrawn.
    totalTokensWithdrawn = totalTokensWithdrawn.add(totalToWithdraw);
    if (totalTokensWithdrawn == vestedLockedAmount + TGEPortion) {
      allTokensWithdrawn = true;
    }
    // Transfer all tokens to user
    token.transfer(user, totalToWithdraw);
  }

  function withdrawReflections() external onlyOwner {
    if (allTokensWithdrawn) {
      uint256 reflections = token.balanceOf(address(this));
      if (reflections > 0) {
        token.transfer(owner, reflections);
      }
      emit LogWithdrawReflections(owner, reflections);
    } else {
      uint256 contractBalanceWReflections = token.balanceOf(address(this));
      uint256 reflections = contractBalanceWReflections - (vestedLockedAmount + TGEPortion);
      if (reflections > 0) {
        token.transfer(owner, reflections);
      }
      emit LogWithdrawReflections(owner, reflections);
    }
  }

  function withdrawDividends(address _token) external onlyOwner {
    require(_token != address(token), "Can't withdraw locked token");
    uint256 dividends = IERC20(_token).balanceOf(address(this));
    if (dividends > 0) {
      IERC20(_token).transfer(owner, dividends);
    }
    emit LogWithdrawDividends(owner, dividends);
  }

  function isPortionUnlocked(uint256 portionId) public view returns (bool) {
    return block.timestamp >= distributionDates[portionId];
  }

  // Get all distribution dates
  function getDistributionDates() external view returns (uint256[] memory) {
    return distributionDates;
  }

  function getAddress() external view returns (address) {
    return address(this);
  }
}
