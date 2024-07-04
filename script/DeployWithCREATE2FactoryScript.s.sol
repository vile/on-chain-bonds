// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Forge
import {Script} from "forge-std/Script.sol";

// Local
import {BondERC20} from "../src/BondERC20.sol";
import {NonUpgradeableBondERC20Beacon} from "../src/proxy/NonUpgradeableBondERC20Beacon.sol";
import {BondERC20ProxyFactory} from "../src/BondERC20ProxyFactory.sol";

interface KeylessCREATE2Factory {
    function safeCreate2(bytes32 salt, bytes calldata initializationCode)
        external
        payable
        returns (address deplymentAddress);

    function hasBeenDeployed(address deploymentAddress) external view returns (bool);
}

contract DeployWithCREATE2FactoryScript is Script {
    // https://github.com/ProjectOpenSea/seaport/blob/main/docs/Deployment.md
    // https://etherscan.io/address/0x0000000000ffe8b47b3e2130213b802212439497
    address private constant KEYLESS_CREATE2_FACTORY = 0x0000000000FFe8B47B3e2130213B802212439497;

    // Salts (for deployer: 0x2F5106Cc200E804c2233D204FF817d4313604469)
    // !!! CHANGE TO YOUR OWN SALTS WHEN DEPLOYING -- SEE ../util/CreactionCodeScript.s.sol !!!
    bytes32 private constant IMPL_SALT = 0x2f5106cc200e804c2233d204ff817d4313604469531d3f2f75125f02880bcc28;
    bytes32 private constant BEACON_SALT = 0x2f5106cc200e804c2233d204ff817d431360446971b0c944e4b62102e57a1ed0;
    bytes32 private constant FACTORY_SALT = 0x2f5106cc200e804c2233d204ff817d4313604469f149cbc05ec3760012eff3f5;

    // Init code (same as `vm.getCode()`)
    bytes private constant IMPL_CREATION_CODE = type(BondERC20).creationCode;
    bytes private constant BEACON_CREATION_CODE = type(NonUpgradeableBondERC20Beacon).creationCode;
    bytes private constant FACTORY_CREATION_CODE = type(BondERC20ProxyFactory).creationCode;

    // Known before hand, allows for partial deployments incase of some failure during script execution
    address private constant IMPL_KNOWN_ADDRESS = 0x0000000a9900006ee5AEe818870B573e3F00EFdE;
    address private constant BEACON_KNOWN_ADDRESS = 0x00000000002A68e045fcF1b392cD1C53D4A400aA;
    address private constant FACTORY_KNOWN_ADDRESS = 0x00000000000d2F16966bD08eb4424a60E8C9008e;

    function run() external returns (address implAddress, address beaconAddress, address factoryAddress) {
        KeylessCREATE2Factory c2Factory = KeylessCREATE2Factory(KEYLESS_CREATE2_FACTORY);

        vm.startBroadcast();

        if (!c2Factory.hasBeenDeployed(IMPL_KNOWN_ADDRESS)) {
            implAddress = c2Factory.safeCreate2(IMPL_SALT, IMPL_CREATION_CODE);
        } else {
            implAddress = IMPL_KNOWN_ADDRESS;
        }

        if (!c2Factory.hasBeenDeployed(BEACON_KNOWN_ADDRESS)) {
            beaconAddress =
                c2Factory.safeCreate2(BEACON_SALT, abi.encodePacked(BEACON_CREATION_CODE, abi.encode(implAddress)));
        } else {
            beaconAddress = BEACON_KNOWN_ADDRESS;
        }

        if (!c2Factory.hasBeenDeployed(FACTORY_KNOWN_ADDRESS)) {
            factoryAddress =
                c2Factory.safeCreate2(FACTORY_SALT, abi.encodePacked(FACTORY_CREATION_CODE, abi.encode(beaconAddress)));
        } else {
            factoryAddress = FACTORY_KNOWN_ADDRESS;
        }

        vm.stopBroadcast();
    }
}
