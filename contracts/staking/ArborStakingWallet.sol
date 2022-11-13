// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IStakingToken.sol";

contract ArborStakingWallet is Ownable {
  IStakingToken public immutable mainToken;
  address public deployer;

  event LogRewardsWithdrawal(address indexed receiver, uint256 amount);
  event LogTokenRecovery(address tokenRecovered, uint256 amount);

  constructor(IStakingToken _mainToken, address _stakingContract) {
    mainToken = _mainToken;
    deployer = msg.sender;
    transferOwnership(_stakingContract);
  }

  modifier onlyOwnerOrDeployer() {
    require(owner() == _msgSender() || deployer == _msgSender(), "Ownable: caller is not the owner or deployer");
    _;
  }

  function withdrawReward(address receiver, uint256 _amount) external onlyOwnerOrDeployer {
    require(mainToken.balanceOf(address(this)) >= _amount, "Insufficient reward balance");

    address _dividendToken = IStakingToken(mainToken).dividendToken();

    uint256 amountDividenToWithdraw = _getDividenShare(_amount);

    /**
     * withdraw dividend
     */
    if (amountDividenToWithdraw > 0) {
      IERC20(_dividendToken).transfer(receiver, _amount);
    }
    mainToken.transfer(receiver, _amount);
    emit LogRewardsWithdrawal(receiver, _amount);
  }

  function _getDividenShare(uint256 _amount) internal view returns (uint256) {
    address _dividendToken = IStakingToken(mainToken).dividendToken();
    uint256 _contractBalance = mainToken.balanceOf(address(this));
    uint256 _dividendBalance = IERC20(_dividendToken).balanceOf(address(this));

    if (_dividendBalance == 0) {
      return 0;
    }

    uint256 amountDividend = (_amount * _dividendBalance) / _contractBalance;
    return amountDividend;
  }

  function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwnerOrDeployer {
    address _dividendToken = IStakingToken(mainToken).dividendToken();

    require(_tokenAddress != address(mainToken), "Cannot be main token");
    require(_tokenAddress != address(_dividendToken), "Cannot be main dividenToken");

    IERC20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);

    emit LogTokenRecovery(_tokenAddress, _tokenAmount);
  }
}
