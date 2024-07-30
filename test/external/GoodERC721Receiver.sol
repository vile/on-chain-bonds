// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

// External
import {NFTPurchaser} from "./abstract/NFTPurchaser.sol";

// Library
import {IERC721Receiver} from "@openzeppelin-contracts-5.0.2/token/ERC721/IERC721Receiver.sol";

contract GoodERC721Receiver is NFTPurchaser, IERC721Receiver {
    constructor(address erc, address bond) NFTPurchaser(erc, bond) {}

    function onERC721Received(
        address, /* operator */
        address, /* from */
        uint256, /* tokenId */
        bytes calldata /* data */
    ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
