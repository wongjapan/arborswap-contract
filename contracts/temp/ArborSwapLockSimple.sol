// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract ArborSwapLockSimple {
  using SafeMath for uint256;
  uint256 public lockedAmount;
  uint256 public fee;
  uint256 public unlockDate;
  address public owner;
  address public factory;
  IERC20 public token;
  bool public tokensWithdrawn;
  bool public tokensLocked;

  event LogLock(uint256 unlockDate, uint256 lockedAmount);
  event LogWithdraw(address to, uint256 lockedAmount);
  event LogWithdrawReflections(address to, uint256 amount);
  event LogWithdrawDividends(address to, uint256 dividends);
  event LogWithdrawNative(address to, uint256 dividends);
  event LockUpdated(uint256 newAmount, uint256 newUnlockDate);

  modifier onlyOwner() {
    require(msg.sender == owner, "ONLY_OWNER");
    _;
  }

  modifier onlyOwnerOrFactory() {
    require(msg.sender == owner || msg.sender == factory, "ONLY_OWNER_OR_FACTORY");
    _;
  }

  constructor(
    address _owner,
    uint256 _unlockDate,
    uint256 amount,
    address _token,
    address _factory
  ) {
    require(_owner != address(0), "Invalid owner address");
    owner = _owner;
    unlockDate = _unlockDate;
    lockedAmount = amount;
    token = IERC20(_token);
    factory = _factory;
  }

  function lock() public payable onlyOwnerOrFactory {
    require(tokensLocked == false, "ALREADY_LOCKED");
    tokensLocked = true;
    emit LogLock(unlockDate, lockedAmount);
  }

  function editLock(uint256 newAmount, uint256 newUnlockDate) external onlyOwner {
    require(tokensWithdrawn == false, "ALREADY_UNLOCKED");

    if (newUnlockDate > 0) {
      require(newUnlockDate >= unlockDate && newUnlockDate > block.timestamp, "BAD_TIME_INPUT");
      unlockDate = newUnlockDate;
    }

    if (newAmount > 0) {
      require(newAmount >= lockedAmount, "BAD_INPUT_AMOUNT");

      uint256 diff = newAmount - lockedAmount;

      if (diff > 0) {
        lockedAmount = newAmount;
        token.transferFrom(msg.sender, address(this), diff);
      }
    }

    emit LockUpdated(newAmount, newUnlockDate);
  }

  function unlock() external onlyOwner {
    require(block.timestamp >= unlockDate, "WRONG_TIME");
    require(tokensWithdrawn == false, "ALREADY_UNLOCKED");

    tokensWithdrawn = true;

    token.transfer(owner, lockedAmount);

    emit LogWithdraw(owner, lockedAmount);
  }

  function withdrawReflections() external onlyOwner {
    if (tokensWithdrawn) {
      uint256 reflections = token.balanceOf(address(this));
      if (reflections > 0) {
        token.transfer(owner, reflections);
      }
      emit LogWithdrawReflections(owner, reflections);
    } else {
      uint256 contractBalanceWReflections = token.balanceOf(address(this));
      uint256 reflections = contractBalanceWReflections - lockedAmount;
      if (reflections > 0) {
        token.transfer(owner, reflections);
      }
      emit LogWithdrawReflections(owner, reflections);
    }
  }

  function withdrawDividends(address _token) external onlyOwner {
    require(_token != address(token), "CANT_WITHDRAW_LOCKED_ASSETS");
    uint256 dividends = IERC20(_token).balanceOf(address(this));
    if (dividends > 0) {
      IERC20(_token).transfer(owner, dividends);
    }
    emit LogWithdrawDividends(owner, dividends);
  }

  function withdrawBNB() external onlyOwner {
    uint256 amount = address(this).balance;
    payable(owner).transfer(amount);
    emit LogWithdrawNative(owner, amount);
  }

  /**
   * for receive dividend
   */
  receive() external payable {}
}
