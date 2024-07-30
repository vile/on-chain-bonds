// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

// Base
import {BaseTest} from "../BaseTest.t.sol";

contract RenounceOnwershipTest is BaseTest {
    function test_WhenAttemptingToRenounce() external {
        _deployBondInstance();

        vm.prank(bondDeployer);
        bond.renounceOwnership();

        // it should result in no state change
        assertEq(address(bondDeployer), bond.owner());
    }
}
