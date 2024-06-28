// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {BaseBeaconProxy} from "../abstracts/BaseBeaconProxy.sol";

/// @title BondERC20BeaconProxy
/// @author Vile (https://github.com/vile)
/// @notice Beacon proxy for each instance of a BondERC20.
contract BondERC20BeaconProxy is BaseBeaconProxy {
    /// @dev Marked payable to reduce gas cost. Not intended to recieve any Ether on construction. See implementation's `rescueEther`.
    constructor(address beacon, bytes memory data) payable BaseBeaconProxy(beacon, data) {}
}
