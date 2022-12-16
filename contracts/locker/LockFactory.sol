// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./TokenLock.sol";
import "./LiquidityLock.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./ArborSwapDeps/IUniswapV2Pair.sol";
import "./ArborSwapDeps/IUniswapV2Factory.sol";

interface IAdmin {
  function isAdmin(address user) external view returns (bool);
}

contract LockFactory is Ownable {
  using SafeERC20 for IERC20;
  struct FeeInfo {
    uint256 liquidityFee;
    uint256 normalFee;
    uint256 vestingFee;
    address payable feeReceiver;
  }

  IAdmin public admin;
  FeeInfo public fee;

  address[] public tokenLock;
  address[] public liquidityLock;

  mapping(address => address[]) public tokenLockOwner;
  mapping(address => address[]) public liquidityLockOwner;
  mapping(uint256 => address) public liquidityLockIdToAddress;
  mapping(uint256 => address) public tokenLockIdToAddress;

  event LogSetFee(string feeType, uint256 newFee);
  event LogSetFeeReceiver(address newFeeReceiver);
  event LogCreateTokenLock(address lock, address owner);
  event LogCreateLiquidityLock(address lock, address owner);

  constructor(address _adminContract) {
    require(_adminContract != address(0), "ADDRESS_ZERO");
    admin = IAdmin(_adminContract);
  }

  modifier onlyAdmin() {
    require(admin.isAdmin(msg.sender), "NOT_ADMIN");
    _;
  }

  function createTokenLock(
    address _owner,
    address _token,
    uint256 _amount,
    uint256 _unlockDate,
    string memory _logoImage
  ) external payable {
    require(_owner != address(0), "ADDRESS_ZERO");
    require(msg.value >= fee.normalFee, "BAD_FEE");
    require(IERC20(_token).balanceOf(msg.sender) >= _amount, "NOT_ENOUGH_TOKEN");
    require(IERC20(_token).allowance(msg.sender, address(this)) >= _amount, "BAD_ALLOWANCE");

    TokenLock lock = new TokenLock(_owner, _unlockDate, _amount, _token, address(this), _logoImage);
    address createdLock = address(lock);

    uint256 id = tokenLock.length;
    tokenLockIdToAddress[id] = createdLock;
    tokenLockOwner[_owner].push(createdLock);
    tokenLock.push(createdLock);
    _safeTransferExactAmount(_token, msg.sender, createdLock, _amount);
    fee.feeReceiver.transfer(msg.value);
    emit LogCreateTokenLock(createdLock, _owner);
  }

  function createLiquidityLock(
    address _owner,
    address _token,
    uint256 _amount,
    uint256 _unlockDate,
    string memory _logoImage
  ) external payable {
    require(_owner != address(0), "ADDRESS_ZERO");
    address lpFactory = _parseFactoryAddress(_token);
    require(_isValidLpToken(_token, lpFactory), "NOT_VALID_LP_TOKEN");
    require(msg.value >= fee.liquidityFee, "BAD_FEE");
    require(IERC20(_token).balanceOf(msg.sender) >= _amount, "NOT_ENOUGH_TOKEN");
    require(IERC20(_token).allowance(msg.sender, address(this)) >= _amount, "BAD_ALLOWANCE");

    LiquidityLock lock = new LiquidityLock(_owner, _unlockDate, _amount, _token, address(this), _logoImage);
    address createdLock = address(lock);

    uint256 id = liquidityLock.length;
    liquidityLockIdToAddress[id] = createdLock;
    liquidityLockOwner[_owner].push(createdLock);
    liquidityLock.push(createdLock);
    _safeTransferExactAmount(_token, msg.sender, createdLock, _amount);
    fee.feeReceiver.transfer(msg.value);
    emit LogCreateLiquidityLock(createdLock, _owner);
  }

  function setNormalFee(uint256 _fee) public onlyAdmin {
    require(fee.normalFee != _fee, "BAD_INPUT");
    fee.normalFee = _fee;
    emit LogSetFee("Normal Fee", _fee);
  }

  function setLiquidityFee(uint256 _fee) public onlyAdmin {
    require(fee.liquidityFee != _fee, "BAD_INPUT");
    fee.liquidityFee = _fee;
    emit LogSetFee("Liquidity Fee", _fee);
  }

  function setVestingFee(uint256 _fee) public onlyAdmin {
    require(fee.vestingFee != _fee, "BAD_INPUT");
    fee.vestingFee = _fee;
    emit LogSetFee("Vesting Fee", _fee);
  }

  function setFeeReceiver(address payable _receiver) public onlyAdmin {
    require(_receiver != address(0), "ADDRESS_ZERO");
    require(fee.feeReceiver != _receiver, "BAD_INPUT");
    fee.feeReceiver = _receiver;
    emit LogSetFeeReceiver(_receiver);
  }

  // GETTER FUNCTION

  function getTokenLock(uint256 startIndex, uint256 endIndex) external view returns (address[] memory) {
    require(endIndex > startIndex, "BAD_INPUT");
    require(endIndex <= tokenLock.length, "OUT_OF_RANGE");

    address[] memory tempLock = new address[](endIndex - startIndex);
    uint256 index = 0;

    for (uint256 i = startIndex; i < endIndex; i++) {
      tempLock[index] = tokenLock[i];
      index++;
    }

    return tempLock;
  }

  function getLiquidityLock(uint256 startIndex, uint256 endIndex) external view returns (address[] memory) {
    require(endIndex > startIndex, "BAD_INPUT");
    require(endIndex <= liquidityLock.length, "OUT_OF_RANGE");

    address[] memory tempLock = new address[](endIndex - startIndex);
    uint256 index = 0;

    for (uint256 i = startIndex; i < endIndex; i++) {
      tempLock[index] = liquidityLock[i];
      index++;
    }

    return tempLock;
  }

  function getTotalTokenLock() external view returns (uint256) {
    return tokenLock.length;
  }

  function getTotalLiquidityLock() external view returns (uint256) {
    return liquidityLock.length;
  }

  function getTokenLockAddress(uint256 id) external view returns (address) {
    return tokenLockIdToAddress[id];
  }

  function getLiquidityLockAddress(uint256 id) external view returns (address) {
    return liquidityLockIdToAddress[id];
  }

  function getLastTokenLock() external view returns (address) {
    if (tokenLock.length > 0) {
      return tokenLock[tokenLock.length - 1];
    }
    return address(0);
  }

  function getLastLiquidityLock() external view returns (address) {
    if (liquidityLock.length > 0) {
      return liquidityLock[liquidityLock.length - 1];
    }
    return address(0);
  }

  // UTILITY

  function _safeTransferExactAmount(
    address token,
    address sender,
    address recipient,
    uint256 amount
  ) internal {
    uint256 oldRecipientBalance = IERC20(token).balanceOf(recipient);
    IERC20(token).safeTransferFrom(sender, recipient, amount);
    uint256 newRecipientBalance = IERC20(token).balanceOf(recipient);
    require(newRecipientBalance - oldRecipientBalance == amount, "NOT_EQUAL_TRANFER");
  }

  function _parseFactoryAddress(address token) internal view returns (address) {
    address possibleFactoryAddress;
    try IUniswapV2Pair(token).factory() returns (address factory) {
      possibleFactoryAddress = factory;
    } catch {
      revert("NOT_LP_TOKEN");
    }
    require(possibleFactoryAddress != address(0) && _isValidLpToken(token, possibleFactoryAddress), "NOT_LP_TOKEN.");
    return possibleFactoryAddress;
  }

  function _isValidLpToken(address token, address factory) private view returns (bool) {
    IUniswapV2Pair pair = IUniswapV2Pair(token);
    address factoryPair = IUniswapV2Factory(factory).getPair(pair.token0(), pair.token1());
    return factoryPair == token;
  }
}
