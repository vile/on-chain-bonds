// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Forge
import {Script} from "forge-std/Script.sol";

// Local
import {BondERC20} from "../src/BondERC20.sol";
import {NonUpgradeableBondERC20Beacon} from "../src/proxy/NonUpgradeableBondERC20Beacon.sol";
import {BondERC20ProxyFactory} from "../src/BondERC20ProxyFactory.sol";

contract DeployScript is Script {
    function run() external returns (BondERC20, NonUpgradeableBondERC20Beacon, BondERC20ProxyFactory) {
        vm.startBroadcast();
        BondERC20 bondERC20 = new BondERC20();
        NonUpgradeableBondERC20Beacon beacon = new NonUpgradeableBondERC20Beacon({implementation_: address(bondERC20)});
        BondERC20ProxyFactory proxyFactory = new BondERC20ProxyFactory({bondERC20Beacon: address(beacon)});
        vm.stopBroadcast();

        return (bondERC20, beacon, proxyFactory);
    }
}
