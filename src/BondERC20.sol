// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Bond} from "./abstracts/Bond.sol";
import {BondEvents} from "./libraries/BondEvents.sol";
import {BondErrors} from "./libraries/BondErrors.sol";

import {IERC20} from "@openzeppelin-contracts-5.0.2/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin-contracts-5.0.2/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@solady-0.0.227/utils/ReentrancyGuard.sol";

/// @title BondERC20
/// @author Vile (https://github.com/vile)
/// @notice ERC20 implementation of the Bond contract.
/// @notice THIS CONTRACT IS NOT INTENDED FOR USE WITH FEE-ON-TRANSFER, REBASING, YIELD, INFLATIONARY/DEFLATIONARY, OR UN-BUNRABLE TOKENS.
/// @notice AVOID USING SUCH TOKENS OR USE WRAPPERS (e.g., wstETH) WHERE POSSIBLE.
/// @notice LOSSES RESULTING FROM THE USE OF THESE TOKENS ARE THE INDEPENDENT DEPLOYER'S/USER'S FAULT.
contract BondERC20 is Bond, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @inheritdoc Bond
    function initialize(
        address _owner,
        address beneficiary,
        address bondToken,
        uint256 bondPrice,
        bool shouldBurnBonds,
        string memory erc721Name,
        string memory erc721Symbol,
        string memory erc721URI
    ) external payable override initializer {
        if (_owner == address(0)) revert BondErrors.Bond__ZeroAddress();
        if (beneficiary == address(0)) revert BondErrors.Bond__ZeroAddress();
        if (bondToken == address(0)) revert BondErrors.Bond__ZeroAddress();
        if (bondPrice == 0) revert BondErrors.Bond__PriceCannotBeZero();

        s_beneficiary = beneficiary;
        s_bondToken = bondToken;
        s_bondPrice = bondPrice;
        s_shouldBurnBonds = shouldBurnBonds;

        // ERC721 Metadata
        s_erc721Name = erc721Name;
        s_erc721Symbol = erc721Symbol;
        s_erc721URI = erc721URI;

        _initializeOwner(_owner);

        emit BondEvents.BondCreated(_owner, beneficiary, bondToken, bondPrice, shouldBurnBonds);
    }

    /// @dev [override] - implemented
    /// @dev Uses `nonReentrant` due to the use of `_safeMint`
    /// @inheritdoc Bond
    function _buyBond(address purchaser, address bondRecipient) internal override nonReentrant {
        // Pull tokens from `purchaser`. Reverts on non-approval, insufficient approval, or insufficient balance.
        IERC20(s_bondToken).safeTransferFrom(purchaser, address(this), s_bondPrice);

        // Mint `bondRecipient` their NFT; increment token id for next mint.
        uint256 tokenId = s_tokenId++;
        _safeMint(bondRecipient, tokenId);

        emit BondEvents.BondBought(bondRecipient, tokenId);
    }

    /// @dev [override] - implemented
    /// @inheritdoc Bond
    function _acceptBond(address to, uint256 bondId) internal override {
        // Cache bond owner.
        address bondOwner = ownerOf(bondId);

        // Burn bond NFT.
        _burn(bondId);

        // Transfer underlying bond assets to `to`.
        IERC20(s_bondToken).safeTransfer(to, s_bondPrice);

        emit BondEvents.BondAccepted(bondOwner, to, bondId);
    }

    /// @dev [override] - implemented
    /// @inheritdoc Bond
    function _rejectBond(uint256 bondId) internal override {
        // Cache bond owner.
        address bondOwner = ownerOf(bondId);

        // Burn bond NFT.
        _burn(bondId);

        // Determine where underlying asset is sent (either beneficiary or burned).
        // `recipient` defaults to address(0), but we explicitly set for clarity.
        address recipient;
        s_shouldBurnBonds ? recipient = address(0) : recipient = s_beneficiary;

        // Transfer underlying asset.
        IERC20(s_bondToken).safeTransfer(recipient, s_bondPrice);

        emit BondEvents.BondRejected(bondOwner, bondId, s_shouldBurnBonds);
    }
}
