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

    function run() external returns (address implAddress, address beaconAddress, address factoryAddress) {
        vm.startBroadcast();
        implAddress = KeylessCREATE2Factory(KEYLESS_CREATE2_FACTORY).safeCreate2(IMPL_SALT, IMPL_CREATION_CODE);
        beaconAddress = KeylessCREATE2Factory(KEYLESS_CREATE2_FACTORY).safeCreate2(
            BEACON_SALT, abi.encodePacked(BEACON_CREATION_CODE, abi.encode(implAddress))
        );
        factoryAddress = KeylessCREATE2Factory(KEYLESS_CREATE2_FACTORY).safeCreate2(
            FACTORY_SALT, abi.encodePacked(FACTORY_CREATION_CODE, abi.encode(beaconAddress))
        );
        vm.stopBroadcast();
    }
}
