// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC20} from "@solady/tokens/ERC20.sol";

contract MockERC20 is ERC20 {
    function mint(uint256 amount) external {
        _mint(msg.sender, amount);
    }

    function mintTo(uint256 amount, address to) external {
        _mint(to, amount);
    }

    function name() public view override returns (string memory) {
        return "Mock ERC20 Token";
    }

    /// @dev Returns the symbol of the token.
    function symbol() public view override returns (string memory) {
        return "MOCK";
    }

    /// @dev Returns the decimals places of the token.
    function decimals() public view override returns (uint8) {
        return 18;
    }
}
