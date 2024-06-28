// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @title BondEvents
/// @author Vile (https://github.com/vile)
/// @notice Library containing all emitted events used in Bond.sol-derived contracts.
library BondEvents {
    /// @notice This event is emitted whenever a new Bond(ERC20/ETH) contract is deployed.
    /// @param owner {indexed} The owner of the Bond contract.
    /// @param beneficiary {indexed} The address rejected bonds' tokens are sent to (if they are not burned).
    /// @param bondToken {indexed} The address of the ERC20 token used to buy (and return) bonds in.
    /// @param bondPrice The price of the bond (in the respective token's decimals).
    /// @param shouldBurnBonds Whether or not rejected bonds' underlying tokens should be burned.
    event BondCreated(
        address indexed owner,
        address indexed beneficiary,
        address indexed bondToken,
        uint256 bondPrice,
        bool shouldBurnBonds
    );

    /// @notice This event is emitted whenever a new bond is bought and NFT is minted.
    /// @param bondRecipient {indexed} The address the bond NFT is sent to.
    /// @param bondId {indexed} The token id of the bond NFT.
    event BondBought(address indexed bondRecipient, uint256 indexed bondId);

    /// @notice This event is emitted whenever a bond is accepted, returning the underlying tokens to the current NFT owner.
    /// @param bondOwner {indexed} The token owner.
    /// @param recipient {indexed} The address underlying tokens have been sent to.
    /// @param bondId {indexed} The token id of the bond NFT.
    event BondAccepted(address indexed bondOwner, address indexed recipient, uint256 indexed bondId);

    /// @notice This event is emitted whenever a bond is rejected, either sending the underlying tokens to the `beneficiary` or burning them.
    /// @param bondOwner {indexed} The token owner.
    /// @param bondId {indexed} The token id of the bond NFT.
    /// @param burned {indexed} Whether or not the underlying assets have been burned.
    event BondRejected(address indexed bondOwner, uint256 indexed bondId, bool indexed burned);

    /// @notice This event is emitted whenever a new `beneficiary` is set.
    /// @param oldBeneficiary {indexed} The old beneficiary address.
    /// @param newBeneficiary {indexed} The new beneficiary address.
    event BeneficiaryChanged(address indexed oldBeneficiary, address indexed newBeneficiary);

    /// @notice This event is emitted wehnever Ether is rescued from the contract.
    /// @param amount {indexed} The amount of Ether rescued and sent out of the contract.
    event EtherRescued(uint256 indexed amount);
}
