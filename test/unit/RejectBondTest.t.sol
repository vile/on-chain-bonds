// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

// Local
import {BondEvents} from "../../src/libraries/BondEvents.sol";

// Base
import {BaseTest} from "../BaseTest.t.sol";

// Library
import {Ownable} from "@solady-0.0.227/auth/Ownable.sol";
import {ERC721} from "@solady-0.0.227/tokens/ERC721.sol";

contract RejectBondTest is BaseTest {
    uint256 internal constant TOKEN_ID_EXISTS = 0;
    uint256 internal constant TOKEN_ID_DOESNT_EXIST = 999;
    address internal constant BURN_ADDRESS = address(0xdead);

    function test_WhenTheCallerIsNotTheOwner() external {
        _deployBondInstance();

        vm.startPrank(userOne);
        erc20.mint(BOND_PRICE);
        erc20.approve(address(bond), type(uint256).max);

        bond.buyBond();

        // it should revert with Unauthorized
        vm.expectRevert(Ownable.Unauthorized.selector);
        bond.rejectBond(TOKEN_ID_EXISTS);
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

    /// @dev We have to do some weirdness here due to the fact you cant start pranks back to back
    modifier givenTheTokenIdDoesExist(bool shouldBurn) {
        if (shouldBurn) {
            vm.stopPrank();
            _deployBondInstanceBurnUnderlying();

            vm.startPrank(userOne);
            erc20.mint(BOND_PRICE);
            erc20.approve(address(bond), type(uint256).max);

            bond.buyBond();
            vm.stopPrank();

            vm.startPrank(bondDeployer);
            _;
            vm.stopPrank();
        } else {
            _;
        }
    }

    function test_WhenUnderlyingAssetsShouldBeBurned()
        external
        whenTheCallerIsTheOwner
        givenTheTokenIdDoesExist(true)
    {
        // it should emit BondEvents.BondRejected(bondOwner, bondId, s_shouldBurnBonds)
        vm.expectEmit(true, true, true, true, address(bond));
        emit BondEvents.BondRejected(address(userOne), TOKEN_ID_EXISTS, true);

        bond.rejectBond(TOKEN_ID_EXISTS);

        // it should burn the nft
        assertEq(bond.balanceOf(address(userOne)), 0, "User one still owns a NFT");

        // it should transfer underlying tokens to the zero address
        assertEq(erc20.balanceOf(address(userOne)), 0 ether, "User 1's token balance is not zero");
        assertEq(erc20.balanceOf(address(bond)), 0 ether, "Bond contract's token balance is not zero");
        assertEq(erc20.balanceOf(address(beneficiary)), 0 ether, "Beneficiary's token balance is not zero");
        assertEq(erc20.balanceOf(address(BURN_ADDRESS)), BOND_PRICE, "Tokens were not sent to the burn address");
    }

    function test_WhenUnderlyingAssetsShouldNotBeBurned()
        external
        whenTheCallerIsTheOwner
        givenTheTokenIdDoesExist(false)
    {
        // it should emit BondEvents.BondRejected(bondOwner, bondId, s_shouldBurnBonds)
        vm.expectEmit(true, true, true, true, address(bond));
        emit BondEvents.BondRejected(address(userOne), TOKEN_ID_EXISTS, false);

        bond.rejectBond(TOKEN_ID_EXISTS);

        // it should burn the nft
        assertEq(bond.balanceOf(address(userOne)), 0, "User one still owns a NFT");

        // it should transfer underlying tokens to the beneficiary address
        assertEq(erc20.balanceOf(address(userOne)), 0 ether, "User 1's token balance is not zero");
        assertEq(erc20.balanceOf(address(bond)), 0 ether, "Bond contract's token balance is not zero");
        assertEq(
            erc20.balanceOf(address(beneficiary)),
            BOND_PRICE,
            "Beneficiary's token balance has not increased to the bond price"
        );
    }
}
