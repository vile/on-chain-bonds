// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Local
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

// Test
import {TestBase} from "../TestBase.sol";

contract NonUpgradeableBondERC20BeaconTest is TestBase {
    /// @dev Function selector for `upgradeTo(address)`
    bytes4 private constant UPGRADE_TO_SIG = hex"3659cfe6";

    /// @notice Except implementation to be set in beacon.
    /// @notice Assert that the beacon implementation is set, and not is not the zero address (unset).
    function test_beaconImplementationIsSet() public {
        address beaconImpl = beacon.implementation();
        assertNotEq(beaconImpl, address(0));
        assertEq(address(bondERC20), beaconImpl);
    }

    /// @notice Except `upgradeTo` calls to fail (function does not exist).
    /// @notice Assert that the `upgradeTo` function does not exist
    function test_RevertBeaconCannotBeUpgrade() public {
        address implBefore = beacon.implementation();
        (bool succ,) = address(beacon).call(abi.encodeWithSelector(UPGRADE_TO_SIG, address(0xDEAD)));
        address implAfter = beacon.implementation();

        assertFalse(succ);
        assertEq(implBefore, implAfter);
    }
}
