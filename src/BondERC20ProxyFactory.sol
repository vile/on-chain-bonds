// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {BondERC20} from "./BondERC20.sol";
import {BondERC20BeaconProxy} from "./proxy/BondERC20BeaconProxy.sol";
import {BondERC20ProxyFactoryEvents} from "./libraries/BondERC20ProxyFactoryEvents.sol";
import {BondERC20ProxyFactoryErrors} from "./libraries/BondERC20ProxyFactoryErrors.sol";

/// @title BondERC20BeaconProxy
/// @author Vile (https://github.com/vile)
/// @notice Proxy factory which creates new instances of beacon proxies for every instance of BondERC20.
/// @notice Using a (non-upgradeable) beacon proxy pattern saves significant gas, as each instance only deploys a minimal beacon proxy
/// @notice and calls out to a single beacon to find an implementation, instead of having to deploy the same code across every instance.
contract BondERC20ProxyFactory {
    /// @notice Non-upgradeable beacon for BondERC20 implementation.
    address private immutable i_BondERC20Beacon;

    // slither-disable-start locked-ether
    /// @dev Marked payable to reduce gas cost. Not intended to recieve any Ether on construction. Ether is un-recoverable.
    constructor(address bondERC20Beacon) payable {
        if (bondERC20Beacon == address(0)) revert BondERC20ProxyFactoryErrors.ProxyFactory__ZeroAddress();

        i_BondERC20Beacon = bondERC20Beacon;

        emit BondERC20ProxyFactoryEvents.FactoryDeployed(address(this));
    }
    // slither-disable-end locked-ether

    // slither-disable-start locked-ether
    /// @notice Deploy a new beacon proxy instance.
    /// @param beneficiary The address which recieves reject bonds' underlying assets, if they are not burned.
    /// @param bondToken The ERC20 token address (e.g., USDC, WETH, etc.) which is paid (and returned) for bonds.
    /// @param bondPrice The price of a bond in (denominated in `bondToken`, with decimals).
    /// @param shouldBurnBonds Whether or not underlying bond assets should be burned or not.
    /// @param erc721Name The name for bond NFTs (should* follow the convention: "NAME PRICE Bond", e.g., "USD Coin 1000 Bond" for a bond using 1,000 USDC excl. decimals).
    /// @param erc721Symbol The symbol for bond NFTs (should* follow the convention: "SYMBOL-PRICE-BOND", e.g., "USDC-1000-BOND" for a bond using 1,000 USDC excl. decimals).
    /// @param erc721URI The URI for bond NFTs (URIs are NOT unique per NFT, see `tokenURI()`).
    function deployNewBondERC20Proxy(
        address beneficiary,
        address bondToken,
        uint256 bondPrice,
        bool shouldBurnBonds,
        string memory erc721Name,
        string memory erc721Symbol,
        string memory erc721URI
    ) external payable returns (address newProxy) {
        newProxy = address(
            new BondERC20BeaconProxy(
                i_BondERC20Beacon,
                abi.encodeCall(
                    BondERC20.initialize,
                    (
                        msg.sender,
                        beneficiary,
                        bondToken,
                        bondPrice,
                        shouldBurnBonds,
                        erc721Name,
                        erc721Symbol,
                        erc721URI
                    )
                )
            )
        );

        emit BondERC20ProxyFactoryEvents.ProxyCreated(address(this), newProxy);
    }
    // slither-disable-end locked-ether

    /// @notice Gets the BondERC20 beacon address.
    function getBeacon() external view returns (address beacon) {
        beacon = i_BondERC20Beacon;
    }
}
