// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

// Local
import {BondERC20} from "../../src/BondERC20.sol";
import {NonUpgradeableBondERC20Beacon as NUBeacon} from "../../src/proxy/NonUpgradeableBondERC20Beacon.sol";
import {BondERC20ProxyFactory} from "../../src/BondERC20ProxyFactory.sol";

import {BondEvents} from "../../src/libraries/BondEvents.sol";
import {BondErrors} from "../../src/libraries/BondErrors.sol";

// Base
import {BaseTest} from "../BaseTest.t.sol";

// Library
import {Initializable} from "@openzeppelin-contracts-5.0.2/proxy/utils/Initializable.sol";

contract InitializeTest is BaseTest {
    function test_RevertWhen_TheBaseImplementationInitializerIsCalled() external {
        // it should revert
        vm.prank(bondDeployer);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        impl.initialize({
            _owner: address(bondDeployer),
            beneficiary: address(bondDeployer),
            bondToken: address(erc20),
            bondPrice: 1 ether,
            shouldBurnBonds: false,
            erc721Name: "This",
            erc721Symbol: "Should",
            erc721URI: "ipfs://revert"
        });
    }

    modifier expectBondCreatedEmit(
        address owner,
        address beneficiary_,
        address bondToken,
        uint256 bondPrice,
        bool shouldBurnBonds
    ) {
        vm.expectEmit(true, true, true, true);
        emit BondEvents.BondCreated(owner, beneficiary_, bondToken, bondPrice, shouldBurnBonds);
        _;
    }

    modifier whenInitializingTheProxy() {
        vm.prank(bondDeployer);
        bond = BondERC20(
            factory.deployNewBondERC20Proxy(
                beneficiary, address(erc20), BOND_PRICE, SHOULD_BURN_BONDS, BOND_NAME, BOND_SYMBOL, BOND_URI
            )
        );
        _;
    }

    /// @dev We use this modified version when we need to expect things (events, reverts)
    modifier whenInitializingTheProxyBefore(address beneficiary_, address token, uint256 price) {
        _;
        vm.prank(bondDeployer);
        bond = BondERC20(
            factory.deployNewBondERC20Proxy(
                beneficiary_, token, price, SHOULD_BURN_BONDS, BOND_NAME, BOND_SYMBOL, BOND_URI
            )
        );
    }

    function test_WhenInitializingTheProxy()
        external
        expectBondCreatedEmit(address(bondDeployer), beneficiary, address(erc20), BOND_PRICE, SHOULD_BURN_BONDS)
        whenInitializingTheProxy
    {
        // it should set all state variables
        assertEq(address(beneficiary), bond.getBeneficiary(), "Beneficiary was not properly set");
        assertEq(address(erc20), bond.getBondToken(), "Bond token was not properly set");
        assertEq(BOND_PRICE, bond.getBondPrice(), "Bond price was not properly set");
        assertEq(SHOULD_BURN_BONDS, bond.getShouldBurnBonds(), "Bond shouldBurnBonds was not properly set");
        assertEq(BOND_NAME, bond.name(), "Bond name was not properly set");
        assertEq(BOND_SYMBOL, bond.symbol(), "Bond symbol was not properly set");
        assertEq(BOND_URI, bond.tokenURI(0), "Bond token URI was not properly set"); // It does not matter which token we take the URI for

        // it should set the owner
        assertEq(address(bondDeployer), bond.owner(), "Bond instance owner was not properly initialized");

        // it should emit BondEvents.BondCreated with proper parameters
        // done using expectBondCreatedEmit()
    }

    function test_GivenTheBeneficiaryAddressIsZero()
        external
        whenInitializingTheProxyBefore(address(0), address(erc20), BOND_PRICE)
    {
        // it should revert with BondErrors.Bond__ZeroAddress
        vm.expectRevert(BondErrors.Bond__ZeroAddress.selector);
    }

    function test_GivenTheBondTokenAddressIsZero()
        external
        whenInitializingTheProxyBefore(address(beneficiary), address(0), BOND_PRICE)
    {
        // it should revert with BondErrors.Bond__ZeroAddress
        vm.expectRevert(BondErrors.Bond__ZeroAddress.selector);
    }

    function test_GivenTheBondPriceIsZero()
        external
        whenInitializingTheProxyBefore(address(beneficiary), address(erc20), 0 ether)
    {
        // it should revert with BondErrors.Bond__PriceCannotBeZero
        vm.expectRevert(BondErrors.Bond__PriceCannotBeZero.selector);
    }

    function test_WhenACallerTriesToReinitialize() external whenInitializingTheProxy {
        // it should revert with InvalidInitialization
        vm.prank(bondDeployer);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        bond.initialize({
            _owner: address(bondDeployer),
            beneficiary: address(bondDeployer),
            bondToken: address(erc20),
            bondPrice: BOND_PRICE,
            shouldBurnBonds: SHOULD_BURN_BONDS,
            erc721Name: "This",
            erc721Symbol: "Should",
            erc721URI: "ipfs://revert"
        });
    }
}
