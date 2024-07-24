// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {BeaconProxy} from "@openzeppelin-contracts-5.0.2/proxy/beacon/BeaconProxy.sol";

/// @title BaseBeaconProxy
/// @author Vile (https://github.com/vile)
/// @notice Abstract base proxy contract for beacon proxies.
/// @dev We use an abstract base simply for semantics. Derived proxy contract(s) are functionality identical.
abstract contract BaseBeaconProxy is BeaconProxy {
    /// @dev Marked payable to reduce gas cost. Not intended to recieve any Ether on construction.
    constructor(address beacon, bytes memory data) payable BeaconProxy(beacon, data) {}
}
