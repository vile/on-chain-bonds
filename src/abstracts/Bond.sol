// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {IBond} from "../interfaces/IBond.sol";
import {BondEvents} from "../libraries/BondEvents.sol";
import {BondErrors} from "../libraries/BondErrors.sol";

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Ownable} from "@solady/auth/Ownable.sol";
import {ERC721} from "@solady/tokens/ERC721.sol";

/// @title Bond
/// @author Vile (https://github.com/vile)
/// @notice Abstract base contract for core bond functionality. ERC20 and (future) ETH versions of Bond contracts are derived from this contract.
abstract contract Bond is IBond, Ownable, ERC721, Initializable {
    uint16 internal constant PROVIDED_GAS_FOR_CALL = 2_300;

    address internal s_bondToken;
    uint256 internal s_bondPrice;
    bool internal s_shouldBurnBonds;
    address internal s_beneficiary;

    string internal s_erc721Name;
    string internal s_erc721Symbol;
    string internal s_erc721URI;
    uint256 internal s_tokenId;

    /// @inheritdoc IBond
    /// @dev [virtual]
    function initialize(
        address _owner,
        address beneficiary,
        address bondToken,
        uint256 bondPrice,
        bool shouldBurnBonds,
        string memory erc721Name,
        string memory erc721Symbol,
        string memory erc721URI
    ) external payable virtual initializer {}

    /// @inheritdoc IBond
    function buyBond() external {
        _buyBond(msg.sender, msg.sender);
    }

    /// @inheritdoc IBond
    function buyBondFor(address user) external {
        _buyBond(msg.sender, user);
    }

    /// @inheritdoc IBond
    function acceptBond(uint256 bondId) external payable onlyOwner {
        address to = ownerOf(bondId);
        _acceptBond(to, bondId);
    }

    /// @inheritdoc IBond
    function acceptBondBatch(uint256[] calldata bondIds) external payable onlyOwner {
        uint256 bondIdsLength = bondIds.length;
        for (uint256 i; i < bondIdsLength;) {
            address to = ownerOf(bondIds[i]);
            _acceptBond(to, bondIds[i]);
            unchecked { i = i + 1; }// forgefmt: disable-line
        }
    }

    /// @inheritdoc IBond
    function rejectBond(uint256 bondId) external payable onlyOwner {
        _rejectBond(bondId);
    }

    /// @inheritdoc IBond
    function rejectBondBatch(uint256[] calldata bondIds) external payable onlyOwner {
        uint256 bondIdsLength = bondIds.length;

        for (uint256 i; i < bondIdsLength;) {
            _rejectBond(bondIds[i]);
            unchecked { i = i + 1; }// forgefmt: disable-line
        }
    }

    /// @inheritdoc IBond
    function rescueBond(address to, uint256 bondId) external payable onlyOwner {
        _acceptBond(to, bondId);
    }

    /// @inheritdoc IBond
    function changeBeneficiary(address newBeneficiary) external payable onlyOwner {
        if (newBeneficiary == address(0)) revert BondErrors.Bond__ZeroAddress();

        address oldBeneficiary = s_beneficiary;
        s_beneficiary = newBeneficiary;

        emit BondEvents.BeneficiaryChanged(oldBeneficiary, newBeneficiary);
    }

    /// @inheritdoc IBond
    function rescueEther() external payable onlyOwner {
        uint256 balance = address(this).balance;
        // slither-disable-next-line low-level-calls
        (bool succ,) = msg.sender.call{value: balance, gas: PROVIDED_GAS_FOR_CALL}("");
        if (!succ) revert BondErrors.Bond__TransferFailed(msg.sender);

        emit BondEvents.EtherRescued(balance);
    }

    // slither-disable-start dead-code
    /// @dev [virtual]
    /// @dev This function will be overrided in each Bond implementation.
    /// @dev It is expected that NFTs are transferable. If/when accepted, underlying tokens are returned to the current token owner.
    /// @notice Internal logic to purchase a bond. See external `buyBond` and `buyBondFor` higher level functionality.
    /// @param purchaser The address where tokens will be pulled from.
    /// @param bondRecipient The address where the bond NFT will be minted.
    function _buyBond(address purchaser, address bondRecipient) internal virtual {}

    /// @dev [virtual]
    /// @dev This function will be overrided in each Bond implementation.
    /// @dev Tokens are sent to the current owner, not the original minter (if ownership has been transferred or bond was purchase on-behalf-of).
    /// @notice Internal logic to accept a bond. See external `acceptBond` and `acceptBondBatch` higher level functionality.
    /// @param to The address where tokens will be sent.
    /// @param bondId The token id of the bond being accepted.
    function _acceptBond(address to, uint256 bondId) internal virtual {}

    /// @dev [virtual]
    /// @dev This function will be overrided in each Bond implementation.
    /// @dev Un-burnable tokens are not compatable. Tokens MUST be burnable (zero address sendable) since when `s_shouldBurnBonds` is `true`, underlying assets are sent there.
    /// @notice Internal logic to reject a bond. See external `rejectBond` and `rejectBondBatch` higher level functionality.
    /// @param bondId The token id of the bond being rejected.
    function _rejectBond(uint256 bondId) internal virtual {}
    // slither-disable-end dead-code

    /// @inheritdoc IBond
    function getBondPrice() external view returns (uint256 bondPrice) {
        bondPrice = s_bondPrice;
    }

    /// @inheritdoc IBond
    function getBondToken() external view returns (address bondToken) {
        bondToken = s_bondToken;
    }

    /// @inheritdoc IBond
    function getShouldBurnBonds() external view returns (bool shouldBurnBonds) {
        shouldBurnBonds = s_shouldBurnBonds;
    }

    /// @inheritdoc IBond
    function getBeneficiary() external view returns (address beneficiary) {
        beneficiary = s_beneficiary;
    }

    /// @inheritdoc ERC721
    function name() public view override returns (string memory) {
        return s_erc721Name;
    }

    /// @inheritdoc ERC721
    function symbol() public view override returns (string memory) {
        return s_erc721Symbol;
    }

    /// @inheritdoc ERC721
    /// @dev Token URIs are NOT unique per token id; the same URI will be returned for EVERY NFT.
    function tokenURI(uint256 /* id */ ) public view override returns (string memory) {
        return s_erc721URI;
    }

    /// @dev Renouncing ownership, or intentionally transferring ownership to the zero address,
    /// @dev is disallowed as it fundamentally breaks the functionality of Bond contracts.
    function renounceOwnership() public payable override onlyOwner {}
}
