// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

// Local
import {BondEvents} from "../../src/libraries/BondEvents.sol";
import {BondErrors} from "../../src/libraries/BondErrors.sol";

// External
import {GoodERC721Receiver} from "../external/GoodERC721Receiver.sol";
import {BadERC721Receiver} from "../external/BadERC721Receiver.sol";
import {TryReenterBuyBond} from "../external/TryReenterBuyBond.sol";

// Base
import {BaseTest} from "../BaseTest.t.sol";

// Library
import {ERC721} from "@solady-0.0.227/tokens/ERC721.sol";
import {IERC20Errors} from "@openzeppelin-contracts-5.0.2/interfaces/draft-IERC6093.sol";
import {ReentrancyGuard} from "@solady-0.0.227/utils/ReentrancyGuard.sol";

contract BuyBondTest is BaseTest {
    /// @dev Generic bond instance user 2 (non-owner receiver/`to`)
    address internal immutable userTwo = makeAddr("userTwo");

    modifier whenTheCallerHasASufficientApprovalAndTokenBalance() {
        _deployBondInstance();

        vm.startPrank(userOne);
        erc20.mint(BOND_PRICE);
        erc20.approve(address(bond), type(uint256).max);
        vm.stopPrank();
        _;
    }

    function test_WhenTheCallerHasASufficientApprovalAndTokenBalance()
        external
        whenTheCallerHasASufficientApprovalAndTokenBalance
    {
        // it should emit BondEvents.BondBought with proper parameters
        vm.expectEmit(true, true, true, true, address(bond));
        emit BondEvents.BondBought(address(userTwo), 0);

        // it should successfully purchase the bond
        vm.prank(userOne);
        bond.buyBondFor(address(userTwo));

        // forgefmt: disable-start
        assertEq(erc20.balanceOf(address(userOne)), 0 ether, "User 1's token balance was not decreased properly");
        assertEq(erc20.balanceOf(address(userTwo)), 0 ether, "User 2's token balance should never increase solely after a purchase");
        assertEq(erc20.balanceOf(address(bond)), BOND_PRICE, "Bond contract did not receive the correct amount of tokens");
        assertTrue(bond.ownerOf(0) == address(userTwo), "User 2 does not own bond token ID #0");
        // forgefmt: disable-end
    }

    function test_GivenTheReceiverIsAContractWithOnERC721Received()
        external
        whenTheCallerHasASufficientApprovalAndTokenBalance
    {
        GoodERC721Receiver good = new GoodERC721Receiver(address(erc20), address(bond));

        // it should successfully purchase the bond
        vm.prank(userOne);
        bond.buyBondFor(address(good));

        // forgefmt: disable-start
        assertEq(erc20.balanceOf(address(userOne)), 0 ether, "User 1's token balance was not decreased properly");
        assertEq(erc20.balanceOf(address(good)), 0 ether, "Good contract's token balance should never increase solely after a purchase");
        assertEq(erc20.balanceOf(address(bond)), BOND_PRICE, "Bond contract did not receive the correct amount of tokens");
        assertTrue(bond.ownerOf(0) == address(good));
        // forgefmt: disable-end
    }

    function test_RevertGiven_TheReceiverIsAContractWithoutOnERC721Received()
        external
        whenTheCallerHasASufficientApprovalAndTokenBalance
    {
        BadERC721Receiver bad = new BadERC721Receiver(address(erc20), address(bond));

        // it should revert
        vm.prank(userOne);
        vm.expectRevert(ERC721.TransferToNonERC721ReceiverImplementer.selector);
        bond.buyBondFor(address(bad));

        // forgefmt: disable-start
        assertEq(erc20.balanceOf(address(userOne)), BOND_PRICE, "User 1's token balance is not equla to the bond price");
        assertEq(erc20.balanceOf(address(bad)), 0 ether, "Bad contract's token balance should not increase");
        assertEq(erc20.balanceOf(address(bond)), 0 ether, "Bond purchase should revert and not increase token balance");
        assertEq(bond.balanceOf(address(bad)), 0, "Bond purchase should revert and not increase NFT balance");
        // forgefmt: disable-end
    }

    function test_RevertWhen_TheCallerHasAnInsufficientApproval() external {
        _deployBondInstance();

        vm.prank(userOne);
        erc20.mint(BOND_PRICE);
        // Dont approve tokens

        // it should revert
        vm.prank(userOne);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, address(bond), 0 ether, BOND_PRICE)
        );
        bond.buyBondFor(address(userTwo));

        // forgefmt: disable-start
        assertEq(erc20.balanceOf(address(userOne)), BOND_PRICE, "User 1's token balance changed when it should not have");
        assertEq(erc20.balanceOf(address(bond)), 0 ether, "Bond contract token balance changed when it should not have");
        assertEq(bond.balanceOf(address(userTwo)), 0, "Bond purchase should revert and not increase NFT balance");
        // forgefmt: disable-end
    }

    function test_RevertWhen_TheCallerHasAnInsufficientTokenBalance() external {
        _deployBondInstance();

        vm.prank(userOne);
        // Dont mint tokens
        erc20.approve(address(bond), type(uint256).max);

        // it should revert
        vm.prank(userOne);
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientBalance.selector, address(userOne), 0 ether, BOND_PRICE
            )
        );
        bond.buyBondFor(address(userTwo));

        // forgefmt: disable-start
        assertEq(erc20.balanceOf(address(userOne)), 0 ether, "User 1's token balance should still be zero");
        assertEq(erc20.balanceOf(address(bond)), 0 ether, "Bond contract token balance should still be zero");
        assertEq(bond.balanceOf(address(userTwo)), 0, "Bond purchase should revert and not increase NFT balance");
        // forgefmt: disable-end
    }
}
