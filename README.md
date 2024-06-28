# On Chain Bonds

A (kind-of) decentralized and (relatively) gas-efficient protocol for deploying and managing general purpose on-chain bonds, represented as ERC721 (NFT) tokens. 

## Protocol Architecture

Simply put, the protocol is *mostly* decentralized and completely un-owned.
However, individual instances of Bonds are **not** un-owned, but potentially can be decentralized.

The initial protocol deployment consists are three (3) parts:

1) BondERC20 Implementation
2) Non-Upgradeable Beacon
3) Beacon Proxy Factory

<details>
<summary>General Architecture Diagram</summary>
<br/>

<img src=".assets/images/1-general-architecture.png" alt="Diagram showing the general architecture of the protocol"/>

</details>

Then, entities who are interested in using the protocol, can deploy a beacon proxy (using the proxy factory), which creates as new "instance" of an independently owned Bond.
The initial owner is the proxy contract caller, but ownership can be transferred to, say, a multi-sig operated by a decentralized governance strucuture.

Beyond this extra step and external infrastructure, the owner of the Bond instance has the final say in "accepting" or "rejecting" bonds.
And, therefore, without a decentralized instance owner, all users who mint bonds **must** trust the owner to act in good faith.
Ownership is required for each Bond instance to function; there is no other way to properly handle accepting or rejecting bonds, as each instance can have arbitrary, socialized rulesets that may/must be evaludated by human judgement.