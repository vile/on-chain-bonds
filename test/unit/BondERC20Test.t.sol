// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Local
import {BondERC20} from "../../src/BondERC20.sol";
import {BondEvents} from "../../src/libraries/BondEvents.sol";

import {ERC20} from "@solady/tokens/ERC20.sol";
import {ERC721} from "@solady/tokens/ERC721.sol";

// Test
import {TestBase} from "../TestBase.sol";

contract BondERC20Test is TestBase {
    uint256 internal constant BOND_PRICE = 100 ether;
    string tokenName = "Mock ERC20 100 Token";
    string tokenSymbol = "MOCK-100-BOND";
    string tokenUri = "ipfs://real-uri/image.png";

    address internal USER_THREE = makeAddr("userThree"); // Generic user

    BondERC20 internal latestProxy;

    /// @notice Deploy a new proxy instance.
    /// @param shouldBurnBonds Whether or not bonds should be burned when rejected.
    modifier createProxy(bool shouldBurnBonds) {
        vm.prank(USER_ONE); // Independent instance deployer
        latestProxy = BondERC20(
            proxyFactory.deployNewBondERC20Proxy(
                address(BENEFICIARY), address(mockToken), BOND_PRICE, shouldBurnBonds, tokenName, tokenSymbol, tokenUri
            )
        );
        vm.label(address(latestProxy), "Bond Proxy Instance");
        _;
    }

    /// @dev `to` will usually be address(USER_TWO).
    /// @notice Prank as USER_TWO, mint Mock token, mint bond.
    /// @param proxy Bond (proxy) instance.
    /// @param to Address to purchase for.
    modifier userTwoMintBond(BondERC20 proxy, address to) {
        vm.startPrank(USER_TWO);
        mockToken.mint(BOND_PRICE);
        mockToken.approve(address(proxy), type(uint256).max);
        proxy.buyBondFor(to);
        vm.stopPrank();
        _;
    }

    /// @notice Prank the entire test as `USER_TWO`.
    modifier prankUserTwo() {
        vm.startPrank(USER_TWO);
        _;
        vm.stopPrank();
    }

    /// @notice Prank the entire test as `USER_ONE` (bond instance owner).
    modifier prankBondInstanceOwner() {
        vm.startPrank(USER_ONE);
        _;
        vm.stopPrank();
    }

    /*
    ** > Public & External Functions
    */

    /// @notice Assert that bonds are minted properly, and underlying tokens are transferred.
    function test_buyBond() public createProxy(false) prankUserTwo {
        mockToken.mint(BOND_PRICE);
        mockToken.approve(address(latestProxy), type(uint256).max);
        latestProxy.buyBond();

        assertEq(mockToken.balanceOf(address(USER_TWO)), 0 ether);
        assertEq(mockToken.balanceOf(address(latestProxy)), BOND_PRICE);
        assertEq(latestProxy.balanceOf(address(USER_TWO)), 1);
    }

    /// @notice Except revert when apporval is insufficient.
    /// @notice Assert Bond NFT balance is still zero.
    function test_RevertBuyBondFailsWithoutApproval() public createProxy(false) prankUserTwo {
        mockToken.mint(BOND_PRICE);
        vm.expectRevert(ERC20.InsufficientAllowance.selector);
        latestProxy.buyBond();

        assertEq(mockToken.balanceOf(address(latestProxy)), 0);
        assertEq(latestProxy.balanceOf(address(USER_TWO)), 0);
    }

    /// @notice Except revert when token balance is insufficient.
    /// @notice Assert Bond NFT balance is still zero.
    function test_RevertBuyBondFailsWithoutTokens() public createProxy(false) prankUserTwo {
        mockToken.approve(address(latestProxy), type(uint256).max);
        vm.expectRevert(ERC20.InsufficientBalance.selector);
        latestProxy.buyBond();

        assertEq(latestProxy.balanceOf(address(USER_TWO)), 0);
    }

    /// @notice Assert that bonds are minted properly (for), and underlying tokens are transferred.
    function test_buyBondFor() public createProxy(false) prankUserTwo {
        mockToken.mint(BOND_PRICE);
        mockToken.approve(address(latestProxy), type(uint256).max);
        latestProxy.buyBondFor(address(USER_THREE));

        assertEq(mockToken.balanceOf(address(USER_TWO)), 0 ether);
        assertEq(mockToken.balanceOf(address(USER_THREE)), 0 ether);
        assertEq(mockToken.balanceOf(address(latestProxy)), BOND_PRICE);
        assertEq(latestProxy.balanceOf(address(USER_THREE)), 1);
    }

    /// @notice Except revert when apporval is insufficient.
    /// @notice Assert Bond NFT balance is still zero.
    function test_RevertBuyBondForFailsWithoutApproval() public createProxy(false) prankUserTwo {
        mockToken.mint(BOND_PRICE);
        vm.expectRevert(ERC20.InsufficientAllowance.selector);
        latestProxy.buyBondFor(address(USER_THREE));

        assertEq(mockToken.balanceOf(address(latestProxy)), 0);
        assertEq(latestProxy.balanceOf(address(USER_THREE)), 0);
    }

    /// @notice Except revert when token balance is insufficient.
    /// @notice Assert Bond NFT balance is still zero.
    function test_RevertBuyBondForFailsWithoutTokens() public createProxy(false) prankUserTwo {
        mockToken.approve(address(latestProxy), type(uint256).max);
        vm.expectRevert(ERC20.InsufficientBalance.selector);
        latestProxy.buyBondFor(address(USER_THREE));

        assertEq(mockToken.balanceOf(address(latestProxy)), 0 ether);
        assertEq(latestProxy.balanceOf(address(USER_THREE)), 0);
    }

    /*
    ** > onlyOwner Functions
    */

    /// @notice Expect bond to be properly burned, and have underlying ERC20 tokens transferred to the Bond owner.
    /// @notice Assert USER_TWO NFT balance is zero, and token balances are properly transferred.
    function test_acceptBondTokenExists()
        public
        createProxy(false)
        userTwoMintBond(latestProxy, address(USER_TWO))
        prankBondInstanceOwner
    {
        uint256 tokenId = 0;

        vm.expectEmit(true, true, true, false, address(latestProxy));
        emit BondEvents.BondAccepted(address(USER_TWO), address(USER_TWO), tokenId);
        latestProxy.acceptBond(tokenId);

        assertEq(latestProxy.balanceOf(address(USER_TWO)), 0);
        assertEq(mockToken.balanceOf(address(USER_TWO)), BOND_PRICE);
        assertEq(mockToken.balanceOf(address(latestProxy)), 0 ether);
    }

    /// @notice Expect the bond acceptance to fail due to the token id not existing.
    /// @notice Assert that USER_TWO NFT balance is still one, and token balances have not changed.
    function test_RevertAcceptBondTokenDoesntExists()
        public
        createProxy(false)
        userTwoMintBond(latestProxy, address(USER_TWO))
        prankBondInstanceOwner
    {
        uint256 tokenId = 1; // Token Id does not exist yet.

        vm.expectRevert(ERC721.TokenDoesNotExist.selector);
        latestProxy.acceptBond(tokenId);

        assertEq(latestProxy.balanceOf(address(USER_TWO)), 1);
        assertEq(mockToken.balanceOf(address(USER_TWO)), 0 ether);
        assertEq(mockToken.balanceOf(address(latestProxy)), BOND_PRICE);
    }

    /// @notice Expect all bonds to be accepted and have underlying tokens transferred back.
    /// @notice Assert that USER_TWO and USER_THREE NFT balance is zero, and token balances are properly transferred.
    function test_acceptBondBatch()
        public
        createProxy(false)
        userTwoMintBond(latestProxy, address(USER_TWO))
        userTwoMintBond(latestProxy, address(USER_THREE))
        prankBondInstanceOwner
    {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 0;
        tokenIds[1] = 1;

        // We should expect ALL BondAccepted events, but it gets very verbose due to intermediate `latestProxy` events.
        vm.expectEmit(true, true, true, false, address(latestProxy));
        emit BondEvents.BondAccepted(address(USER_TWO), address(USER_TWO), tokenIds[0]);
        latestProxy.acceptBondBatch(tokenIds);

        assertEq(latestProxy.balanceOf(address(USER_TWO)), 0);
        assertEq(latestProxy.balanceOf(address(USER_THREE)), 0);
        assertEq(mockToken.balanceOf(address(USER_TWO)), BOND_PRICE);
        assertEq(mockToken.balanceOf(address(USER_THREE)), BOND_PRICE);
        assertEq(mockToken.balanceOf(address(latestProxy)), 0 ether);
    }

    /// @notice Expect bond to be properly burned, and underlying tokens are transferred to `beneficiary`.
    /// @notice Assert USER_TWO NFT balance is zero, and beneficiary token balance has increased.
    function test_rejectBondTokenExistsNotBurned()
        public
        createProxy(false)
        userTwoMintBond(latestProxy, address(USER_TWO))
        prankBondInstanceOwner
    {
        uint256 tokenId = 0;

        vm.expectEmit(true, true, true, false, address(latestProxy));
        emit BondEvents.BondRejected(address(USER_TWO), tokenId, false);
        latestProxy.rejectBond(tokenId);

        assertEq(latestProxy.balanceOf(address(USER_TWO)), 0);
        assertEq(mockToken.balanceOf(address(USER_TWO)), 0 ether);
        assertEq(mockToken.balanceOf(address(BENEFICIARY)), BOND_PRICE);
        assertEq(mockToken.balanceOf(address(latestProxy)), 0 ether);
    }

    /// @notice Expect bond to be properly burned, and underlying tokens are burned.
    /// @notice Assert USER_TWO NFT balance is zero, and beneficiary token balance is still zero (meaning tokens have been burned).
    function test_rejectBondTokenExistsBurned()
        public
        createProxy(true)
        userTwoMintBond(latestProxy, address(USER_TWO))
        prankBondInstanceOwner
    {
        uint256 tokenId = 0;

        vm.expectEmit(true, true, true, false, address(latestProxy));
        emit BondEvents.BondRejected(address(USER_TWO), tokenId, true);
        latestProxy.rejectBond(tokenId);

        assertEq(latestProxy.balanceOf(address(USER_TWO)), 0);
        assertEq(mockToken.balanceOf(address(USER_TWO)), 0 ether);
        assertEq(mockToken.balanceOf(address(BENEFICIARY)), 0 ether);
        assertEq(mockToken.balanceOf(address(latestProxy)), 0 ether);
    }

    /// @notice Expect bond rejection to fail due to the token id not existing.
    /// @notice Assert USER_TWO NFT balance is still one, underlying token balances have not changed.
    function test_RevertRejectBondTokenDoesntExist()
        public
        createProxy(false)
        userTwoMintBond(latestProxy, address(USER_TWO))
        prankBondInstanceOwner
    {
        uint256 tokenId = 1; // Token Id does not exist yet.

        vm.expectRevert(ERC721.TokenDoesNotExist.selector);
        latestProxy.rejectBond(tokenId);

        assertEq(latestProxy.balanceOf(address(USER_TWO)), 1);
        assertEq(mockToken.balanceOf(address(USER_TWO)), 0 ether);
        assertEq(mockToken.balanceOf(address(latestProxy)), BOND_PRICE);
        assertEq(mockToken.balanceOf(address(BENEFICIARY)), 0 ether);
    }

    /// @notice Expect all bonds to be rejected and have underlying tokens transferred to the `beneficiary`.
    /// @notice Assert USER_TWO and USER_THREE NFT balance is zero, and beneficiary token balance has increased.
    function test_rejectBondBatchNotBurned()
        public
        createProxy(false)
        userTwoMintBond(latestProxy, address(USER_TWO))
        userTwoMintBond(latestProxy, address(USER_THREE))
        prankBondInstanceOwner
    {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 0;
        tokenIds[1] = 1;

        // We should expect ALL BondRejected events, but it gets very verbose due to intermediate `latestProxy` events.
        vm.expectEmit(true, true, true, false, address(latestProxy));
        emit BondEvents.BondRejected(address(USER_TWO), tokenIds[0], false);
        latestProxy.rejectBondBatch(tokenIds);

        assertEq(latestProxy.balanceOf(address(USER_TWO)), 0);
        assertEq(latestProxy.balanceOf(address(USER_THREE)), 0);
        assertEq(mockToken.balanceOf(address(USER_TWO)), 0 ether);
        assertEq(mockToken.balanceOf(address(USER_THREE)), 0 ether);
        assertEq(mockToken.balanceOf(address(latestProxy)), 0 ether);
        assertEq(mockToken.balanceOf(address(BENEFICIARY)), BOND_PRICE * 2);
    }

    /// @notice Expect all bonds to be rejected and have underlying tokens to be burned.
    /// @notice Assert USER_TWO and USER_THREE NFT balance is zero, and and beneficiary token balance is still zero (meaning tokens have been burned)
    function test_rejectBondBatchBurned()
        public
        createProxy(true)
        userTwoMintBond(latestProxy, address(USER_TWO))
        userTwoMintBond(latestProxy, address(USER_THREE))
        prankBondInstanceOwner
    {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 0;
        tokenIds[1] = 1;

        // We should expect ALL BondRejected events, but it gets very verbose due to intermediate `latestProxy` events.
        vm.expectEmit(true, true, true, false, address(latestProxy));
        emit BondEvents.BondRejected(address(USER_TWO), tokenIds[0], true);
        latestProxy.rejectBondBatch(tokenIds);

        assertEq(latestProxy.balanceOf(address(USER_TWO)), 0);
        assertEq(latestProxy.balanceOf(address(USER_THREE)), 0);
        assertEq(mockToken.balanceOf(address(USER_TWO)), 0 ether);
        assertEq(mockToken.balanceOf(address(USER_THREE)), 0 ether);
        assertEq(mockToken.balanceOf(address(latestProxy)), 0 ether);
        assertEq(mockToken.balanceOf(address(BENEFICIARY)), 0 ether);
    }

    /// @notice Expect bond rescue to succeed.
    /// @notice Assert USER_TWO NFT balance is zero, and USER_THREE token balance has increased.
    function test_rescueBond()
        public
        createProxy(false)
        userTwoMintBond(latestProxy, address(USER_TWO))
        prankBondInstanceOwner
    {
        uint256 tokenId = 0;

        vm.expectEmit(true, true, true, false, address(latestProxy));
        emit BondEvents.BondAccepted(address(USER_TWO), address(USER_THREE), tokenId);
        latestProxy.rescueBond(address(USER_THREE), tokenId);

        assertEq(latestProxy.balanceOf(address(USER_TWO)), 0);
        assertEq(mockToken.balanceOf(address(USER_TWO)), 0 ether);
        assertEq(mockToken.balanceOf(address(USER_THREE)), BOND_PRICE);
        assertEq(mockToken.balanceOf(address(latestProxy)), 0 ether);
    }

    /// @notice Expect beneficiary to update properly.
    /// @notice Assert beneficiary has been updated.
    function testFuzz_changeBeneficiary(address newBeneficiary) public createProxy(false) prankBondInstanceOwner {
        vm.assume(newBeneficiary != address(0));

        vm.expectEmit();
        emit BondEvents.BeneficiaryChanged(latestProxy.getBeneficiary(), newBeneficiary);
        latestProxy.changeBeneficiary(newBeneficiary);

        assertEq(latestProxy.getBeneficiary(), newBeneficiary);
    }

    /// @notice Expect Ether rescue to succeed.
    /// @notice Assert Ether balances update accordingly throughout the test.
    function test_rescueEther()
        public
        createProxy(false)
        userTwoMintBond(latestProxy, address(USER_TWO))
        prankBondInstanceOwner
    {
        uint256 tokenId = 0;
        uint256 rescueEtherAmount = 1 ether;
        vm.deal(USER_ONE, rescueEtherAmount);

        latestProxy.acceptBond{value: rescueEtherAmount}(tokenId);
        assertEq(address(latestProxy).balance, rescueEtherAmount);
        assertEq(address(USER_ONE).balance, 0 ether);

        latestProxy.rescueEther();
        assertEq(address(latestProxy).balance, 0 ether);
        assertEq(address(USER_ONE).balance, rescueEtherAmount);
    }
}
