// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

// Local
import {BondErrors} from "../../src/libraries/BondErrors.sol";
import {BondEvents} from "../../src/libraries/BondEvents.sol";

// Base
import {BaseTest} from "../BaseTest.t.sol";

// Library
import {Ownable} from "@solady-0.0.227/auth/Ownable.sol";

contract ChangeBeneficiaryTest is BaseTest {
    function test_RevertWhen_TheCallerIsNotTheOwner() external {
        _deployBondInstance();

        // it should revert
        vm.prank(userOne);
        vm.expectRevert(Ownable.Unauthorized.selector);
        bond.changeBeneficiary(address(0xdeadbeef));
    }

    modifier whenTheCallerIsTheOwner() {
        _deployBondInstance();

        vm.startPrank(bondDeployer);
        _;
        vm.stopPrank();
    }

    function test_GivenTheNewBeneficiaryIsTheZeroAddress() external whenTheCallerIsTheOwner {
        // it should revert with BondErrors.Bond__ZeroAddress
        vm.expectRevert(BondErrors.Bond__ZeroAddress.selector);
        bond.changeBeneficiary(address(0));
    }

    function test_GivenTheNewBeneficiaryIsNotTheZeroAddress() external whenTheCallerIsTheOwner {
        address newBeneficiary = address(0xc0ffee);

        // it should emit BondEvents.BeneficiaryChanged(oldBeneficiary, newBeneficiary)
        vm.expectEmit(true, true, true, true, address(bond));
        emit BondEvents.BeneficiaryChanged(address(beneficiary), address(newBeneficiary));

        bond.changeBeneficiary(newBeneficiary);

        // it should update s_beneficiary
        assertEq(bond.getBeneficiary(), newBeneficiary);
    }
}
