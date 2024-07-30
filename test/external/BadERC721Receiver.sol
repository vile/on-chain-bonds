// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

// External
import {NFTPurchaser} from "./abstract/NFTPurchaser.sol";

contract BadERC721Receiver is NFTPurchaser {
    constructor(address erc, address bond) NFTPurchaser(erc, bond) {}
}
