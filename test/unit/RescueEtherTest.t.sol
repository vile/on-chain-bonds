// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

// Local
import {BondERC20} from "../../src/BondERC20.sol";

import {BondEvents} from "../../src/libraries/BondEvents.sol";

// External
import {BadETHReceiver as BadReceiver} from "../external/BadETHReceiver.sol";

// Base
import {BaseTest} from "../BaseTest.t.sol";

// Library
import {SafeTransferLib} from "@solady-0.0.227/utils/SafeTransferLib.sol";

contract RescueEtherTest is BaseTest {
    function test_WhenTheCallerCanReceiveEther() external {
        _deployBondInstance();

        uint256 amountToRescue = 1 ether;
        hoax(bondDeployer, amountToRescue);
        bond.changeBeneficiary{value: amountToRescue}(address(beneficiary));

        assertEq(address(bond).balance, amountToRescue, "Bond contract did not receive the correct amount of Ether");
        assertEq(address(bondDeployer).balance, 0 ether, "Bond instance deployer did not send all of it's Ether");

        // it should emit BondEvents.EtherRescued(amount)
        vm.expectEmit(true, false, false, false, address(bond));
        emit BondEvents.EtherRescued(amountToRescue);

        // it should transfer the entire ether balanace
        vm.prank(bondDeployer);
        bond.rescueEther();

        assertEq(address(bond).balance, 0 ether, "Bond contract did not send all of it's Ether");
        assertEq(
            address(bondDeployer).balance,
            amountToRescue,
            "Bond instance deployer did not receive the correct amount of Ether"
        );
    }

    function test_WhenTheCallerCanNotReceiveEther() external {
        _deployBondInstance();

        BadReceiver badReceiver = new BadReceiver(address(bond));

        uint256 amountToRescue = 1 ether;
        hoax(bondDeployer, amountToRescue);
        bond.transferOwnership{value: amountToRescue}(address(badReceiver));

        // it should revert
        vm.expectRevert();
        badReceiver.withdrawEther();
    }
}
