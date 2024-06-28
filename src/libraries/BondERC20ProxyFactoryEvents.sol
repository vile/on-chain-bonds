// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @title BondERC20ProxyFactoryEvents
/// @author Vile (https://github.com/vile)
/// @notice Library containing all emitted events used in BondERC20ProxyFactory.sol.
library BondERC20ProxyFactoryEvents {
    /// @notice This event is emitted when the proxy factory is deployed.
    /// @param factory {indexed} The address of the proxy factory.
    event FactoryDeployed(address indexed factory);

    /// @notice This event is emitted whenever a new BondERC20BeaconProxy is deployed.
    /// @param factory {indexed} The address of the factory the proxy was created from.
    /// @param proxy {indexed} The address of the newly deployed proxy.
    event ProxyCreated(address indexed factory, address indexed proxy);
}
