// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@openzeppelin-contracts-5.0.2/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(uint256 amount) external {
        _mint(msg.sender, amount);
    }

    function mint(uint256 amount, address to) external {
        _mint(to, amount);
    }
}
