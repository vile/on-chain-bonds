// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Local
import {BondERC20ProxyFactory} from "../../src/BondERC20ProxyFactory.sol";

// Test
import {TestBase} from "../TestBase.sol";

contract BondERC20ProxyFactoryFuzz is TestBase {
    /// @notice Expect proxy deployments should succeed, no matter what (within reason).
    function testFuzz_deployExcessiveInstances(
        address proxyDeployer,
        address beneficiary,
        uint256 tokenPrice,
        bool shouldBurn,
        string memory tokenName,
        string memory tokenSymbol,
        string memory tokenURI
    ) public {
        vm.assume(proxyDeployer != address(0));
        vm.assume(beneficiary != address(0));
        tokenPrice = bound(tokenPrice, 1e18, 1_000_000e18);

        vm.prank(proxyDeployer);
        proxyFactory.deployNewBondERC20Proxy(
            beneficiary, address(mockToken), tokenPrice, shouldBurn, tokenName, tokenSymbol, tokenURI
        );
    }
}
