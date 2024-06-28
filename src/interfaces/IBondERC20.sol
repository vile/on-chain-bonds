// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

/// @notice Complete interface (including dependencies) for BondERC20.sol (generated using `cast interface`).
interface IBondERC20 {
    error AccountBalanceOverflow();
    error AlreadyInitialized();
    error BalanceQueryForZeroAddress();
    error Bond__PriceCannotBeZero();
    error Bond__TransferFailed(address to);
    error Bond__ZeroAddress();
    error InvalidInitialization();
    error NewOwnerIsZeroAddress();
    error NoHandoverRequest();
    error NotInitializing();
    error NotOwnerNorApproved();
    error SafeERC20FailedOperation(address token);
    error TokenAlreadyExists();
    error TokenDoesNotExist();
    error TransferFromIncorrectOwner();
    error TransferToNonERC721ReceiverImplementer();
    error TransferToZeroAddress();
    error Unauthorized();

    event Approval(address indexed owner, address indexed account, uint256 indexed id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool isApproved);
    event BeneficiaryChanged(address indexed oldBeneficiary, address indexed newBeneficiary);
    event BondAccepted(address indexed bondOwner, address indexed recipient, uint256 indexed bondId);
    event BondBought(address indexed bondRecipient, uint256 indexed bondId);
    event BondCreated(
        address indexed owner,
        address indexed beneficiary,
        address indexed bondToken,
        uint256 bondPrice,
        bool shouldBurnBonds
    );
    event BondRejected(address indexed bondOwner, uint256 indexed bondId);
    event EtherRescued(uint256 indexed amount);
    event Initialized(uint64 version);
    event OwnershipHandoverCanceled(address indexed pendingOwner);
    event OwnershipHandoverRequested(address indexed pendingOwner);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    function acceptBond(uint256 bondId) external payable;
    function acceptBondBatch(uint256[] memory bondIds) external payable;
    function approve(address account, uint256 id) external payable;
    function balanceOf(address owner) external view returns (uint256 result);
    function buyBond() external;
    function buyBondFor(address user) external;
    function cancelOwnershipHandover() external payable;
    function changeBeneficiary(address newBeneficiary) external payable;
    function completeOwnershipHandover(address pendingOwner) external payable;
    function getApproved(uint256 id) external view returns (address result);
    function getBondPrice() external view returns (uint256 bondPrice);
    function getBondToken() external view returns (address bondToken);
    function getShouldBurnBonds() external view returns (bool shouldBurnBonds);
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
    function isApprovedForAll(address owner, address operator) external view returns (bool result);
    function name() external view returns (string memory);
    function owner() external view returns (address result);
    function ownerOf(uint256 id) external view returns (address result);
    function ownershipHandoverExpiresAt(address pendingOwner) external view returns (uint256 result);
    function rejectBond(uint256 bondId) external payable;
    function rejectBondBatch(uint256[] memory bondIds) external payable;
    function renounceOwnership() external payable;
    function requestOwnershipHandover() external payable;
    function rescueBond(address to, uint256 bondId) external payable;
    function rescueEther() external payable;
    function safeTransferFrom(address from, address to, uint256 id) external payable;
    function safeTransferFrom(address from, address to, uint256 id, bytes memory data) external payable;
    function setApprovalForAll(address operator, bool isApproved) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool result);
    function symbol() external view returns (string memory);
    function tokenURI(uint256) external view returns (string memory);
    function transferFrom(address from, address to, uint256 id) external payable;
    function transferOwnership(address newOwner) external payable;
}
