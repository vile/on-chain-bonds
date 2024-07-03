// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Local
import {BondERC20} from "../../src/BondERC20.sol";
import {BondEvents} from "../../src/libraries/BondEvents.sol";

// Test
import {TestBaseWModifiersForBondERC20} from "../TestBaseWModifiersForBondERC20.sol";

contract BondERC20Fuzz is TestBaseWModifiersForBondERC20 {
    /// @notice Check to see if address is an EOA (has no code).
    /// @param target The target address to check.
    function isEOA(address target) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(target)
        }

        return (size == 0);
    }

    /// @notice Check to see if address implements `onERC721Received`.
    /// @param target The target address to check.
    function isERC721Receiver(address target) internal returns (bool) {
        // selector for `onERC721Received(address,address,uint256,bytes)`
        bytes4 knownSelector = hex"150b7a02";

        (bool succ, bytes memory data) =
            target.call(abi.encodeWithSelector(knownSelector, address(0), address(0), 0, new bytes(0)));

        return (succ && keccak256(data) == keccak256(abi.encodePacked(knownSelector)));
    }

    /// @notice Expect any user to be able to purchase a bond with sufficient token amounts and approval.
    /// @notice Revert if the proxy or purchaser token balance dont update properly, or the purchaser's NFT balance does not increase.
    function testFuzz_buyBond(address purchaser) public createProxy(false) {
        vm.assume(purchaser != address(0) && purchaser != address(latestProxy));
        // Caller must either be an EOA or a contract that implements `onERC721Received` since we use safeMint
        vm.assume(isEOA(purchaser) || isERC721Receiver(purchaser));

        mockToken.mintTo(BOND_PRICE, purchaser);

        uint256 beforeBalanceProxy = mockToken.balanceOf(address(latestProxy));
        uint256 beforeBalancePurchaser = mockToken.balanceOf(purchaser);
        uint256 beforeBalancePurchaserBond = latestProxy.balanceOf(purchaser);

        // User purchases bond
        vm.startPrank(purchaser);
        mockToken.approve(address(latestProxy), type(uint256).max);
        latestProxy.buyBond();
        vm.stopPrank();

        uint256 afterBalanceProxy = mockToken.balanceOf(address(latestProxy));
        uint256 afterBalancePurchaser = mockToken.balanceOf(purchaser);
        uint256 afterBalancePurchaserBond = latestProxy.balanceOf(purchaser);

        assertEq(beforeBalanceProxy + BOND_PRICE, afterBalanceProxy);
        assertEq(beforeBalancePurchaser - BOND_PRICE, afterBalancePurchaser);
        assertEq(beforeBalancePurchaserBond + 1, afterBalancePurchaserBond);
    }

    /// @notice Expect any user to be able to purchase a bond with sufficient token amounts and approval, then have the owner accept their bond and recieve the underlying tokens back.
    /// @notice Revert if the proxy or purchaser token balance dont update properly, or the purchaser's NFT balance does not increase & subsequently decrease.
    function testFuzz_buyBondAndRedeem(address purchaser) public createProxy(false) {
        vm.assume(purchaser != address(0) && purchaser != address(latestProxy));
        // Caller must either be an EOA or a contract that implements `onERC721Received` since we use safeMint
        vm.assume(isEOA(purchaser) || isERC721Receiver(purchaser));

        mockToken.mintTo(BOND_PRICE, purchaser);

        uint256 beforeBalanceProxy = mockToken.balanceOf(address(latestProxy));
        uint256 beforeBalancePurchaser = mockToken.balanceOf(purchaser);
        uint256 beforeBalancePurchaserBond = latestProxy.balanceOf(purchaser);

        // User purchases bond
        vm.startPrank(purchaser);
        mockToken.approve(address(latestProxy), type(uint256).max);
        latestProxy.buyBond();
        vm.stopPrank();

        uint256 afterBalanceProxy = mockToken.balanceOf(address(latestProxy));
        uint256 afterBalancePurchaser = mockToken.balanceOf(purchaser);
        uint256 afterBalancePurchaserBond = latestProxy.balanceOf(purchaser);

        assertEq(beforeBalanceProxy + BOND_PRICE, afterBalanceProxy);
        assertEq(beforeBalancePurchaser - BOND_PRICE, afterBalancePurchaser);
        assertEq(beforeBalancePurchaserBond + 1, afterBalancePurchaserBond);

        // Bond instance owner accepts bond (always token id `0` due to stateless)
        address bondOwner = latestProxy.owner();
        vm.startPrank(bondOwner);
        latestProxy.acceptBond(0);
        vm.stopPrank();

        uint256 redeemBalanceProxy = mockToken.balanceOf(address(latestProxy));
        uint256 redeemBalancePurchaser = mockToken.balanceOf(purchaser);
        uint256 redeemBalancePurchaserBond = latestProxy.balanceOf(purchaser);

        assertEq(redeemBalanceProxy, 0 ether);
        assertEq(redeemBalancePurchaser, BOND_PRICE);
        assertEq(redeemBalancePurchaserBond, 0);
    }

    /// @notice Expect any user to be able to purchase multiple bonds with sufficient token amounts and approval.
    /// @notice Revert if the proxy or purchaser token balance dont update properly, or the purchaser's NFT balance does not increase by the amount of bonds purchased.
    function testFuzz_buyBondMultiple(address purchaser, uint16 amount) public createProxy(false) {
        vm.assume(purchaser != address(0) && purchaser != address(latestProxy));
        // Caller must either be an EOA or a contract that implements `onERC721Received` since we use safeMint
        vm.assume(isEOA(purchaser) || isERC721Receiver(purchaser));

        uint256 BOND_PRICE_MULT = BOND_PRICE * amount;
        mockToken.mintTo(BOND_PRICE_MULT, purchaser);

        uint256 beforeBalanceProxy = mockToken.balanceOf(address(latestProxy));
        uint256 beforeBalancePurchaser = mockToken.balanceOf(purchaser);
        uint256 beforeBalancePurchaserBond = latestProxy.balanceOf(purchaser);

        // User purchases bond
        vm.startPrank(purchaser);
        mockToken.approve(address(latestProxy), type(uint256).max);
        for (uint256 i; i < amount; i++) {
            latestProxy.buyBond();
        }
        vm.stopPrank();

        uint256 afterBalanceProxy = mockToken.balanceOf(address(latestProxy));
        uint256 afterBalancePurchaser = mockToken.balanceOf(purchaser);
        uint256 afterBalancePurchaserBond = latestProxy.balanceOf(purchaser);

        assertEq(beforeBalanceProxy + BOND_PRICE_MULT, afterBalanceProxy);
        assertEq(beforeBalancePurchaser - BOND_PRICE_MULT, afterBalancePurchaser);
        assertEq(beforeBalancePurchaserBond + amount, afterBalancePurchaserBond);
    }

    /// @notice Expect any user to be able to purchase multiple bonds with sufficient token amounts and approval, then have the owner accept their bonds and recieve the underlying tokens back.
    /// @notice Revert if the proxy or purchaser token balance dont update properly, or the purchaser's NFT balance does not increase & subsequently decrease.
    function testFuzz_buyBondMultipleAndRedeem(address purchaser, uint16 amount) public createProxy(false) {
        vm.assume(purchaser != address(0) && purchaser != address(latestProxy));
        // Caller must either be an EOA or a contract that implements `onERC721Received` since we use safeMint
        vm.assume(isEOA(purchaser) || isERC721Receiver(purchaser));

        uint256 BOND_PRICE_MULT = BOND_PRICE * amount;
        mockToken.mintTo(BOND_PRICE_MULT, purchaser);

        uint256 beforeBalanceProxy = mockToken.balanceOf(address(latestProxy));
        uint256 beforeBalancePurchaser = mockToken.balanceOf(purchaser);
        uint256 beforeBalancePurchaserBond = latestProxy.balanceOf(purchaser);

        // User purchases bond
        vm.startPrank(purchaser);
        mockToken.approve(address(latestProxy), type(uint256).max);
        for (uint256 i; i < amount; i++) {
            latestProxy.buyBond();
        }
        vm.stopPrank();

        uint256 afterBalanceProxy = mockToken.balanceOf(address(latestProxy));
        uint256 afterBalancePurchaser = mockToken.balanceOf(purchaser);
        uint256 afterBalancePurchaserBond = latestProxy.balanceOf(purchaser);

        assertEq(beforeBalanceProxy + BOND_PRICE_MULT, afterBalanceProxy);
        assertEq(beforeBalancePurchaser - BOND_PRICE_MULT, afterBalancePurchaser);
        assertEq(beforeBalancePurchaserBond + amount, afterBalancePurchaserBond);

        // Bond instance owner accepts bond (always token id `0` due to stateless)
        address bondOwner = latestProxy.owner();
        vm.startPrank(bondOwner);
        for (uint256 i; i < amount; i++) {
            latestProxy.acceptBond(i);
        }
        vm.stopPrank();

        uint256 redeemBalanceProxy = mockToken.balanceOf(address(latestProxy));
        uint256 redeemBalancePurchaser = mockToken.balanceOf(purchaser);
        uint256 redeemBalancePurchaserBond = latestProxy.balanceOf(purchaser);

        assertEq(redeemBalanceProxy, 0 ether);
        assertEq(redeemBalancePurchaser, BOND_PRICE_MULT);
        assertEq(redeemBalancePurchaserBond, 0);
    }

    /// @notice Expect any user to be able to purchase a bond for another user with sufficient token amounts and approval.
    /// @notice Revert if the proxy or purchaser token balance dont update properly, or the recipient's NFT balance does not increase.
    function testFuzz_buyBondFor(address purchaser, address recipient) public createProxy(false) {
        vm.assume(purchaser != address(0) && purchaser != address(latestProxy));
        vm.assume(recipient != address(0) && recipient != address(latestProxy) && recipient != purchaser);
        // Caller must either be an EOA, and the recipient must be either an EOA or a contract that implements `onERC721Received` since we use safeMint
        vm.assume(isEOA(purchaser) && (isEOA(recipient) || isERC721Receiver(recipient)));

        mockToken.mintTo(BOND_PRICE, purchaser);

        uint256 beforeBalanceProxy = mockToken.balanceOf(address(latestProxy));
        uint256 beforeBalancePurchaser = mockToken.balanceOf(purchaser);
        uint256 beforeBalancePurchaserBond = latestProxy.balanceOf(recipient);

        // User purchases bond
        vm.startPrank(purchaser);
        mockToken.approve(address(latestProxy), type(uint256).max);
        latestProxy.buyBondFor(recipient);
        vm.stopPrank();

        uint256 afterBalanceProxy = mockToken.balanceOf(address(latestProxy));
        uint256 afterBalancePurchaser = mockToken.balanceOf(purchaser);
        uint256 afterBalancePurchaserBond = latestProxy.balanceOf(recipient);

        assertEq(beforeBalanceProxy + BOND_PRICE, afterBalanceProxy);
        assertEq(beforeBalancePurchaser - BOND_PRICE, afterBalancePurchaser);
        assertEq(beforeBalancePurchaserBond + 1, afterBalancePurchaserBond);
        assertEq(latestProxy.balanceOf(purchaser), 0);
    }

    /// @notice Expect any user to be able to purchase a bond for another user with sufficient token amounts and approval, then have the owner accept the recipient's bond and recieve the underlying tokens back.
    /// @notice Revert if the proxy, purchaser, or recipient token balance dont update properly, or the recipient's NFT balance does not increase by the amount of bonds purchased.
    function testFuzz_buyBondForAndRedeem(address purchaser, address recipient) public createProxy(false) {
        vm.assume(purchaser != address(0) && purchaser != address(latestProxy));
        vm.assume(recipient != address(0) && recipient != address(latestProxy) && recipient != purchaser);
        // Caller must either be an EOA, and the recipient must be either an EOA or a contract that implements `onERC721Received` since we use safeMint
        vm.assume(isEOA(purchaser) && (isEOA(recipient) || isERC721Receiver(recipient)));

        mockToken.mintTo(BOND_PRICE, purchaser);

        uint256 beforeBalanceProxy = mockToken.balanceOf(address(latestProxy));
        uint256 beforeBalancePurchaser = mockToken.balanceOf(purchaser);
        uint256 beforeBalancePurchaserBond = latestProxy.balanceOf(recipient);

        // User purchases bond
        vm.startPrank(purchaser);
        mockToken.approve(address(latestProxy), type(uint256).max);
        latestProxy.buyBondFor(recipient);
        vm.stopPrank();

        uint256 afterBalanceProxy = mockToken.balanceOf(address(latestProxy));
        uint256 afterBalancePurchaser = mockToken.balanceOf(purchaser);
        uint256 afterBalancePurchaserBond = latestProxy.balanceOf(recipient);

        assertEq(beforeBalanceProxy + BOND_PRICE, afterBalanceProxy);
        assertEq(beforeBalancePurchaser - BOND_PRICE, afterBalancePurchaser);
        assertEq(beforeBalancePurchaserBond + 1, afterBalancePurchaserBond);
        assertEq(latestProxy.balanceOf(purchaser), 0);

        // Bond instance owner accepts bond (always token id `0` due to stateless)
        address bondOwner = latestProxy.owner();
        vm.startPrank(bondOwner);
        latestProxy.acceptBond(0);
        vm.stopPrank();

        uint256 redeemBalanceProxy = mockToken.balanceOf(address(latestProxy));
        uint256 redeemBalancePurchaser = mockToken.balanceOf(recipient);
        uint256 redeemBalancePurchaserBond = latestProxy.balanceOf(recipient);

        // `recipient` gets underlying tokens
        assertEq(redeemBalanceProxy, 0 ether);
        assertEq(redeemBalancePurchaser, BOND_PRICE);
        assertEq(redeemBalancePurchaserBond, 0);

        // `purchaser` does not
        assertEq(mockToken.balanceOf(purchaser), 0);
        assertEq(latestProxy.balanceOf(purchaser), 0);
    }

    /// @notice Expect beneficiary to update properly, and the proper event is emitted.
    /// @notice Assert beneficiary has been updated.
    function testFuzz_changeBeneficiary(address newBeneficiary) public createProxy(false) prankBondInstanceOwner {
        vm.assume(newBeneficiary != address(0));

        vm.expectEmit();
        emit BondEvents.BeneficiaryChanged(latestProxy.getBeneficiary(), newBeneficiary);
        latestProxy.changeBeneficiary(newBeneficiary);

        assertEq(latestProxy.getBeneficiary(), newBeneficiary);
    }
}
