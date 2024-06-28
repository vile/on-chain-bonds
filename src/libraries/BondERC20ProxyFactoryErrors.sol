// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @title BondERC20ProxyFactoryErrors
/// @author Vile (https://github.com/vile)
/// @notice Library containing all errors used in BondERC20ProxyFactory.sol.
library BondERC20ProxyFactoryErrors {
    /// @notice Supplied address cannot be the zero address.
    error ProxyFactory__ZeroAddress();
}
