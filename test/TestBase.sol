// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Forge
import {Test} from "forge-std/Test.sol";

// Mock
import {MockERC20} from "./mocks/MockERC20.sol";

// Local
import {BondERC20} from "../src/BondERC20.sol";
import {IBondERC20} from "../src/interfaces/IBondERC20.sol";
import {NonUpgradeableBondERC20Beacon} from "../src/proxy/NonUpgradeableBondERC20Beacon.sol";
import {BondERC20ProxyFactory} from "../src/BondERC20ProxyFactory.sol";

abstract contract TestBase is Test {
    address internal DEPLOYER = makeAddr("deployer"); // Protocol deployer
    address internal BENEFICIARY = makeAddr("beneficiary"); // Generic beneficiary for all tests
    address internal USER_ONE = makeAddr("userOne"); // Independent proxy/bond deployer (user)
    address internal USER_TWO = makeAddr("userTwo"); // User of USER_ONE's bond instance

    MockERC20 internal mockToken;
    BondERC20 internal bondERC20;
    NonUpgradeableBondERC20Beacon internal beacon;
    BondERC20ProxyFactory internal proxyFactory;

    /// @notice Follows the same steps as `TestBase::setUp`, except as a modifier.
    /// @param deployer The address to prank as for protocol deployment.
    modifier createFactoryAndDeps(address deployer) {
        mockToken = new MockERC20();
        vm.startPrank(deployer);
        bondERC20 = new BondERC20();
        beacon = new NonUpgradeableBondERC20Beacon({implementation_: address(bondERC20)});
        proxyFactory = new BondERC20ProxyFactory({bondERC20Beacon: address(beacon)});
        vm.stopPrank();
        _;
    }

    /// @notice Generic setup.
    function setUp() public virtual {
        // Deploy generic mock ERC20 (unowned)
        mockToken = new MockERC20();

        vm.startPrank(DEPLOYER);
        // Deploy implementation
        bondERC20 = new BondERC20();

        // Deploy beacon (with impl address)
        beacon = new NonUpgradeableBondERC20Beacon({implementation_: address(bondERC20)});

        // Deploy proxy factory (with beacon address)
        proxyFactory = new BondERC20ProxyFactory({bondERC20Beacon: address(beacon)});
        vm.stopPrank();

        vm.label(address(DEPLOYER), "Protocol Deployer");
        vm.label(address(USER_ONE), "Independent Deployer");
        vm.label(address(mockToken), "Mock ERC20 Token");
        vm.label(address(bondERC20), "BondERC20 Implementation");
        vm.label(address(beacon), "BondERC20 Beacon");
        vm.label(address(proxyFactory), "BondERC20 Proxy Factory");
    }
}
