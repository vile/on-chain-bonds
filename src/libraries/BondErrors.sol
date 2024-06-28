// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @title BondErrors
/// @author Vile (https://github.com/vile)
/// @notice Library containing all errors used in Bond.sol-derived contracts.
library BondErrors {
    /// @notice Supplied address cannot be the zero address.
    error Bond__ZeroAddress();

    /// @notice Bond price cannot be zero.
    error Bond__PriceCannotBeZero();

    /// @notice Ether transfer (call) failed.
    /// @param to Ether recipient.
    error Bond__TransferFailed(address to);

    /// @notice WETH transfer(From) failed.
    /// @param from The address WETH is coming from.
    /// @param to The address WETH is going to.
    /// @param amount The amount of WETH.
    error Bond__WETHTransferFailed(address from, address to, uint256 amount);
}
