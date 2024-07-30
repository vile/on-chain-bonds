// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

// Local
import {BondERC20} from "../../../src/BondERC20.sol";

// Mock
import {ERC20Mock} from "../../mocks/ERC20Mock.sol";

abstract contract NFTPurchaser {
    ERC20Mock private immutable i_erc;
    BondERC20 private immutable i_bond;

    constructor(address erc, address bond) {
        i_erc = ERC20Mock(erc);
        i_bond = BondERC20(bond);
    }

    function purchaseBond() external {
        i_erc.approve(address(i_bond), type(uint256).max);
        i_bond.buyBond();
    }
}
