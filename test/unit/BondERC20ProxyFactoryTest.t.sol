// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Local
import {BondERC20ProxyFactoryEvents} from "../../src/libraries/BondERC20ProxyFactoryEvents.sol";
import {BondERC20ProxyFactory} from "../../src/BondERC20ProxyFactory.sol";

// Test
import {TestBase} from "../TestBase.sol";

contract BondERC20ProxyFactoryTest is TestBase {
    /// @notice Expect factory deployed event to be emitted.
    /// @notice Assert event is emitted.
    function test_factoryDeploymentEvent() public {
        vm.expectEmit(false, false, false, false);
        emit BondERC20ProxyFactoryEvents.FactoryDeployed(address(0));
        new BondERC20ProxyFactory(address(beacon));
    }

    /// @notice Expect beacon is set.
    /// @notice Assert beacon is set.
    function test_getBeacon() public {
        assertEq(proxyFactory.getBeacon(), address(beacon));
    }
}
