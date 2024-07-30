// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

// Local
import {BondERC20} from "../src/BondERC20.sol";
import {NonUpgradeableBondERC20Beacon as NUBeacon} from "../src/proxy/NonUpgradeableBondERC20Beacon.sol";
import {BondERC20ProxyFactory} from "../src/BondERC20ProxyFactory.sol";

import {BondEvents} from "../src/libraries/BondEvents.sol";
import {BondErrors} from "../src/libraries/BondErrors.sol";

// Mock
import {ERC20Mock} from "./mocks/ERC20Mock.sol";

// Forge
import {Test} from "@forge-std-1.9.1/Test.sol";

contract BaseTest is Test {
    uint256 internal constant BOND_PRICE = 1 ether;
    bool internal constant SHOULD_BURN_BONDS = false;
    string internal constant BOND_NAME = "Mock Token 1 Bond";
    string internal constant BOND_SYMBOL = "MT-1-BOND";
    string internal constant BOND_URI = "ipfs://real-link/image.png";

    /// @dev Deploys the main protocol contracts
    address internal immutable protocolOwner = makeAddr("protocolOwner");
    /// @dev Generic beneficiary address
    address internal immutable beneficiary = makeAddr("beneficiary");
    /// @dev Deploys an independent bond instance
    address internal immutable bondDeployer = makeAddr("bondDeployer");
    /// @dev Generic bond instance user (non-owner)
    address internal immutable userOne = makeAddr("userOne");

    ERC20Mock internal erc20;
    BondERC20 internal impl;
    NUBeacon internal beacon;
    BondERC20ProxyFactory internal factory;
    BondERC20 internal bond;

    function setUp() public {
        vm.startPrank(protocolOwner);
        erc20 = new ERC20Mock("Mock Token", "MT");

        impl = new BondERC20();
        beacon = new NUBeacon({implementation_: address(impl)});
        factory = new BondERC20ProxyFactory({bondERC20Beacon: address(beacon)});
        vm.stopPrank();

        vm.label(address(erc20), "ERC20 Token");
        vm.label(address(impl), "Implementation");
        vm.label(address(beacon), "Implementation Beacon");
        vm.label(address(factory), "Bond Proxy Factory");
    }

    /// @notice Deploy a new BondERC20 instance as `bondDeployer` and assign it to `bond`
    function _deployBondInstance() internal {
        vm.prank(bondDeployer);
        bond = BondERC20(
            factory.deployNewBondERC20Proxy(
                address(beneficiary), address(erc20), BOND_PRICE, SHOULD_BURN_BONDS, BOND_NAME, BOND_SYMBOL, BOND_URI
            )
        );
    }

    /// @notice Deploy a new BondERC20 instance, that burns rejected bonds, as `bondDeployer` and assign it to `bond`
    function _deployBondInstanceBurnUnderlying() internal {
        vm.startPrank(bondDeployer);
        bond = BondERC20(
            factory.deployNewBondERC20Proxy(
                address(beneficiary), address(erc20), BOND_PRICE, true, BOND_NAME, BOND_SYMBOL, BOND_URI
            )
        );
    }
}
