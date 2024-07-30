// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @title IBond
/// @author Vile (https://github.com/vile)
/// @notice Interface for Bond.sol.
interface IBond {
    /// @dev Marked payable to reduce gas cost. Not intended to recieve any Ether on initialization.
    /// @dev If Ether is accidentally sent to this contract, see `rescueEther()`.
    /// @notice Initialize a new bond contract (represented with ERC721 NFT receipts).
    /// @param _owner The address granted ownership of the contract, can call privledge (onlyOwner) functions.
    /// @param beneficiary The address which recieves rejected bonds' underlying assets, if they are not burned.
    /// @param bondToken The ERC20 token address (e.g., USDC, WETH, etc.) which is paid using (and returned in) for bonds.
    /// @param bondPrice The price of a bond (denominated in `bondToken`, with decimals).
    /// @param shouldBurnBonds Whether or not underlying bond assets should be burned or not.
    /// @param erc721Name The name for bond NFTs (should* follow the convention: "NAME PRICE Bond", e.g., "USD Coin 1000 Bond" for a bond using 1,000 USDC excl. decimals).
    /// @param erc721Symbol The symbol for bond NFTs (should* follow the convention: "SYMBOL-PRICE-BOND", e.g., "USDC-1000-BOND" for a bond using 1,000 USDC excl. decimals).
    /// @param erc721URI The URI for bond NFTs (URIs are NOT unique per NFT, see `tokenURI()`).
    function initialize(
        address _owner,
        address beneficiary,
        address bondToken,
        uint256 bondPrice,
        bool shouldBurnBonds,
        string memory erc721Name,
        string memory erc721Symbol,
        string memory erc721URI
    ) external payable;

    /// @notice Purchase a bond.
    function buyBond() external;

    /// @dev Accepted bonds' underlying assets are sent to the current NFT owner, not the original minter.
    /// @notice Purchase a bond on behalf of someone else.
    /// @param user Address to purchase a bond for.
    function buyBondFor(address user) external;

    /// @dev [onlyOwner]
    /// @dev Use `rescueBond` to send underlying assets to an alternative address.
    /// @notice Accept a bond; burn `bondIds[i]` and send the current token owner the underlying tokens.
    /// @param bondId The token id of the bond being accepted.
    function acceptBond(uint256 bondId) external payable;

    /// @dev [onlyOwner]
    /// @notice Reject a bond; burn `bondId` and either burn the underlying tokens, or send them to `beneficiary`.
    /// @param bondId The token id of the bond being rejected.
    function rejectBond(uint256 bondId) external payable;

    /// @dev [onlyOwner]
    /// @dev No "batch" version of this function is available as it shouldn't be commonly used.
    /// @notice Accept a bond and send the underlying assets to an alternative address, `to` (normally the current token owner).
    /// @param to The alternative address to send tokens to.
    /// @param bondId The token id of the bond being rescued (accepted).
    function rescueBond(address to, uint256 bondId) external payable;

    /// @dev [onlyOwner]
    /// @notice Change the `beneficiary` of the contract; the `beneficiary` recieves underlying assets of rejected bonds, if they are not burned.
    /// @param newBeneficiary Address of the new beneficiary (cannot be the zero address).
    function changeBeneficiary(address newBeneficiary) external payable;

    /// @dev [onlyOwner]
    /// @dev It is safe to send the entire Ether balance, including in ETH bond as the contract holds a WETH balance and unwraps WETH on demand (for accepted and rejected bonds).
    /// @notice Send the entire Ether balance of the contract to `msg.sender` (owner).
    function rescueEther() external payable;

    /// @notice Get the bond price (in `bondToken` decimals).
    /// @return bondPrice The price of a bond in `bondToken`.
    function getBondPrice() external view returns (uint256 bondPrice);

    /// @notice Get the underlying token asset of a bond (e.g., USDC).
    /// @return bondToken The address of the `bondToken`.
    function getBondToken() external view returns (address bondToken);

    /// @notice Get whether or not rejected bonds are burned or not.
    /// @return shouldBurnBonds Boolean representing whether or not bonds are burned.
    function getShouldBurnBonds() external view returns (bool shouldBurnBonds);

    /// @notice Get the current beneficiary.
    /// @return beneficiary The address of `beneficiary`.
    function getBeneficiary() external view returns (address beneficiary);
}
