// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Forge
import {Script} from "@forge-std-1.9.1/Script.sol";

contract CreationCodeScript is Script {
    // If you are mining your own, change these addresses as needed
    address private constant IMPL_CREATE2 = 0x0000000a9900006ee5AEe818870B573e3F00EFdE; // (salt 0x2f5106cc200e804c2233d204ff817d4313604469531d3f2f75125f02880bcc28)
    address private constant BEACON_CREATE2 = 0x00000000002A68e045fcF1b392cD1C53D4A400aA; // (salt 0x2f5106cc200e804c2233d204ff817d431360446971b0c944e4b62102e57a1ed0)

    function run()
        external
        view
        returns (bytes32 implInitHash, bytes32 nonUpgradeableBeaconInitHash, bytes32 proxyFactoryInitHash)
    {
        bytes memory implCode = vm.getCode("BondERC20.sol:BondERC20");
        bytes memory beaconCode = vm.getCode("NonUpgradeableBondERC20Beacon.sol:NonUpgradeableBondERC20Beacon");
        bytes memory factoryCode = vm.getCode("BondERC20ProxyFactory.sol:BondERC20ProxyFactory");

        implInitHash = keccak256(abi.encodePacked(implCode));
        nonUpgradeableBeaconInitHash = keccak256(abi.encodePacked(beaconCode, abi.encode(IMPL_CREATE2)));
        proxyFactoryInitHash = keccak256(abi.encodePacked(factoryCode, abi.encode(BEACON_CREATE2)));
    }
}
