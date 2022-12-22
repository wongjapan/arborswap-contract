// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
  constructor(
    string memory _name,
    string memory _symbol,
    address receiver,
    uint256 _supply
  ) ERC20(_name, _symbol) {
    _mint(receiver, _supply);
  }

  //   function decimals() public view virtual override returns (uint8) {
  //     return 9;
  //   }
}
