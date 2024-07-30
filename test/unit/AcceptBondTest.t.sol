// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

// Local
import {BondEvents} from "../../src/libraries/BondEvents.sol";

// Base
import {BaseTest} from "../BaseTest.t.sol";

// Library
import {Ownable} from "@solady-0.0.227/auth/Ownable.sol";
import {ERC721} from "@solady-0.0.227/tokens/ERC721.sol";

contract AcceptBondTest is BaseTest {
    uint256 internal constant TOKEN_ID_EXISTS = 0;
    uint256 internal constant TOKEN_ID_DOESNT_EXIST = 999;

    function test_WhenTheCallerIsNotTheOwner() external {
        _deployBondInstance();

        vm.startPrank(userOne);
        erc20.mint(BOND_PRICE);
        erc20.approve(address(bond), type(uint256).max);
        bond.buyBond();

        // it should revert with Unauthorized
        vm.expectRevert(Ownable.Unauthorized.selector);
        bond.acceptBond(TOKEN_ID_EXISTS);
        vm.stopPrank();

        // forgefmt: disable-start
        assertEq(erc20.balanceOf(address(userOne)), 0 ether, "User 1's token balance increased when it should not have");
        assertEq(erc20.balanceOf(address(bond)), BOND_PRICE, "Bond contract's token balance decreased when it should not have");
        assertEq(erc20.balanceOf(address(beneficiary)), 0 ether, "Beneficiary gained tokens when the bond should not have been accepted");
        assertTrue(bond.ownerOf(TOKEN_ID_EXISTS) == address(userOne), "The NFT no longer exists");
        // forgefmt: disable-end
    }

    modifier whenTheCallerIsTheOwner() {
        _deployBondInstance();

        vm.startPrank(userOne);
        erc20.mint(BOND_PRICE);
        erc20.approve(address(bond), type(uint256).max);

        bond.buyBond();
        vm.stopPrank();

        vm.startPrank(bondDeployer);
        _;
        vm.stopPrank();
    }

    function test_GivenTheTokenIdDoesNotExist() external whenTheCallerIsTheOwner {
        // it should revert with TokenDoesNotExist
        vm.expectRevert(ERC721.TokenDoesNotExist.selector);
        bond.acceptBond(TOKEN_ID_DOESNT_EXIST);

        // forgefmt: disable-start
        assertEq(erc20.balanceOf(address(userOne)), 0 ether, "User 1's token balance increased when it should not have");
        assertEq(erc20.balanceOf(address(bond)), BOND_PRICE, "Bond contract's token balance decreased when it should not have");
        assertEq(erc20.balanceOf(address(beneficiary)), 0 ether, "Beneficiary gained tokens when the bond should not have been accepted");
        assertTrue(bond.ownerOf(TOKEN_ID_EXISTS) == address(userOne), "The NFT no longer exists");
        // forgefmt: disable-end
    }

    function test_GivenTheTokenIdDoesExist() external whenTheCallerIsTheOwner {
        // forgefmt: disable-start
        assertEq(erc20.balanceOf(address(userOne)), 0 ether, "User 1's token balance should be zero");
        assertEq(erc20.balanceOf(address(bond)), BOND_PRICE, "Bond contract' token balance should be the price of a bond");
        // forgefmt: disable-end

        // it should emit BondEvents.BondAccepted(bondOwner, to, bondId)
        vm.expectEmit(true, true, true, true, address(bond));
        emit BondEvents.BondAccepted(address(userOne), address(userOne), TOKEN_ID_EXISTS);

        bond.acceptBond(TOKEN_ID_EXISTS);

        // forgefmt: disable-start
        // it should burn the nft
        vm.expectRevert(ERC721.TokenDoesNotExist.selector);
        bond.ownerOf(TOKEN_ID_EXISTS);

        assertEq(bond.balanceOf(userOne), 0, "User 1 still owns the NFT");

        // it should transfer the underlying tokens to `to`
        assertEq(erc20.balanceOf(address(userOne)), BOND_PRICE, "User 1's token balance should be the price of a bond");
        assertEq(erc20.balanceOf(address(bond)), 0 ether, "Bond contract' token balance should be zero");
        // forgefmt: disable-end
    }
}
