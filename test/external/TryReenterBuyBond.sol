// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

// Local
import {BondERC20} from "../../src/BondERC20.sol";

// Mock
import {ERC20Mock} from "../mocks/ERC20Mock.sol";

// Library
import {IERC721Receiver} from "@openzeppelin-contracts-5.0.2/token/ERC721/IERC721Receiver.sol";

contract TryReenterBuyBond is IERC721Receiver {
    ERC20Mock private immutable i_erc;
    BondERC20 private immutable i_bond;

    constructor(address erc, address bond) {
        i_erc = ERC20Mock(erc);
        i_bond = BondERC20(bond);

        i_erc.approve(address(bond), type(uint256).max);
    }

    function reenter() external {
        i_bond.buyBond();
    }

    function onERC721Received(
        address, /* operator */
        address, /* from */
        uint256, /* tokenId */
        bytes calldata /* data */
    ) external override returns (bytes4) {
        i_bond.buyBond();

        return IERC721Receiver.onERC721Received.selector;
    }
}
