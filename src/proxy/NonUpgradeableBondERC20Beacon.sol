// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IBeacon} from "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";

/// @title NonUpgradeableBondERC20Beacon
/// @author Vile (https://github.com/vile)
/// @author OpenZeppelin (https://github.com/OpenZeppelin)
/// @notice Non-upgradebale version of OZ's Beacon.
/// @dev The only difference between this contract and UpgradeableBeacon, is the removal of `Ownable` and the `upgradeTo` function.
/// @dev Upgradeability is not a planned feature of this protocol, but the beacon proxy architecture makes the most sense, gas-wise.
contract NonUpgradeableBondERC20Beacon is IBeacon {
    address private _implementation;

    /**
     * @dev The `implementation` of the beacon is invalid.
     */
    error BeaconInvalidImplementation(address implementation);

    /**
     * @dev Emitted when the implementation returned by the beacon is changed.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Sets the address of the initial implementation.
     */
    constructor(address implementation_) {
        _setImplementation(implementation_);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function implementation() external view virtual returns (address) {
        return _implementation;
    }

    /**
     * @dev Sets the implementation contract address for this beacon
     *
     * Requirements:
     *
     * - `newImplementation` must be a contract.
     */
    function _setImplementation(address newImplementation) private {
        if (newImplementation.code.length == 0) {
            revert BeaconInvalidImplementation(newImplementation);
        }
        _implementation = newImplementation;
        emit Upgraded(newImplementation);
    }
}
