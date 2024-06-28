// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {TestBase, BondERC20} from "../TestBase.sol";

contract SimpleDeployTest is TestBase {
    /// @notice Deploy a beacon proxy for BondERC20.
    function test_proxyDeployment() public {
        vm.prank(USER_ONE);
        proxyFactory.deployNewBondERC20Proxy(
            address(BENEFICIARY),
            address(mockToken),
            100 ether,
            false,
            "Mock ERC20 100 Bond",
            "MOCK-100-BOND",
            "ipfs://real-uri/thumbnail.png"
        );
    }

    /// @notice Deploy the raw implementation contract.
    /// @notice This is unrealistic, but used for gas comparisons.
    function test_rawDeployment() public {
        vm.startPrank(USER_ONE);
        BondERC20 bondInstance = new BondERC20();
        bondInstance.initialize( // The initalizer is external, but we continue the prank for clarity.
            address(USER_ONE),
            address(BENEFICIARY),
            address(mockToken),
            100 ether,
            false,
            "Mock ERC20 100 Bond",
            "MOCK-100-BOND",
            "ipfs://real-uri/thumbnail.png"
        );
        vm.stopPrank();
    }
}
