// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Local
import {BondERC20} from "../src/BondERC20.sol";

// Test
import {TestBase} from "./TestBase.sol";

abstract contract TestBaseWModifiersForBondERC20 is TestBase {
    uint256 internal constant BOND_PRICE = 100 ether;
    BondERC20 internal latestProxy;

    string tokenName = "Mock ERC20 100 Token";
    string tokenSymbol = "MOCK-100-BOND";
    string tokenUri = "ipfs://real-uri/image.png";

    /// @notice Deploy a new proxy instance.
    /// @param shouldBurnBonds Whether or not bonds should be burned when rejected.
    modifier createProxy(bool shouldBurnBonds) {
        vm.prank(USER_ONE); // Independent instance deployer
        latestProxy = BondERC20(
            proxyFactory.deployNewBondERC20Proxy(
                address(BENEFICIARY), address(mockToken), BOND_PRICE, shouldBurnBonds, tokenName, tokenSymbol, tokenUri
            )
        );
        vm.label(address(latestProxy), "Bond Proxy Instance");
        _;
    }

    /// @dev `to` will usually be address(USER_TWO).
    /// @notice Prank as USER_TWO, mint Mock token, mint bond.
    /// @param proxy Bond (proxy) instance.
    /// @param to Address to purchase for.
    modifier userTwoMintBond(BondERC20 proxy, address to) {
        vm.startPrank(USER_TWO);
        mockToken.mint(BOND_PRICE);
        mockToken.approve(address(proxy), type(uint256).max);
        proxy.buyBondFor(to);
        vm.stopPrank();
        _;
    }

    /// @notice Prank the entire test as `USER_TWO`.
    modifier prankUserTwo() {
        vm.startPrank(USER_TWO);
        _;
        vm.stopPrank();
    }

    /// @notice Prank the entire test as `USER_ONE` (bond instance owner).
    modifier prankBondInstanceOwner() {
        vm.startPrank(USER_ONE);
        _;
        vm.stopPrank();
    }
}
