// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {BondERC20} from "../../src/BondERC20.sol";

contract BadETHReceiver {
    BondERC20 private immutable i_bond;

    constructor(address bond) {
        i_bond = BondERC20(bond);
    }

    function withdrawEther() external {
        i_bond.rescueEther();
    }

    // No receive/fallback
}
