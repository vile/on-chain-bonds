# On Chain Bonds

[![solidity - v0.8.25](https://img.shields.io/badge/solidity-v0.8.25-2ea44f?logo=solidity)](https://soliditylang.org/)
[![Foundry - Latest](https://img.shields.io/static/v1?label=Foundry&message=latest&color=black&logo=solidity&logoColor=white)](https://book.getfoundry.sh/)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)

A (kind-of) decentralized and (relatively) gas-efficient protocol for deploying and managing general purpose on-chain bonds, represented as ERC721 (NFT) tokens. 

This is a sister project of [vile/eth-bonds](https://github.com/vile/eth-bonds), inspired by the same issue.

<center>
<img 
    src=".assets/images/0-chain-links-logo.png"
    alt="AI generated image of a chain"
    style="border-radius: 30%;"
/>
</center>

## Protocol Architecture

Simply put, the protocol is a *mostly* decentralized, completely un-owned, non-upgradeable beacon proxy pattern.
However, individual instances of Bonds **are owned**, but potentially can be decentralized.

The initial protocol deployment consists are three (3) parts:

1) BondERC20 Implementation
2) Non-Upgradeable Beacon
3) Beacon Proxy Factory

<details>
<summary>General Architecture Diagram</summary>
<br/>

<img 
    src=".assets/images/1-general-architecture.png"
    alt="Diagram showing the general architecture of the protocol"
/>

</details>

Entities who are interested in using the protocol, can deploy a beacon proxy (using the proxy factory), which creates a new "instance" of an independently owned Bond.
The initial owner is the proxy contract caller, but ownership can be transferred to, say, a multi-sig operated by a decentralized governance strucuture.

Beyond this extra step and external infrastructure, the owner of the Bond instance has the final say in "accepting" or "rejecting" bonds.
And, therefore, without a decentralized instance owner, all users who mint bonds **must** trust the owner to act in good faith.
Ownership is required for each Bond instance to function; there is no other way to properly handle accepting or rejecting bonds, as each instance can have arbitrary, socialized rulesets that may/must be evaludated by human judgement.

## Getting Started

### Requirements

1. Git - [Install Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
   1. Check if you have Git installed with `git --version`
2. Foundry - [Install Foundry](https://getfoundry.sh/)
   1. Check if you have Foundry installed with `forge --version`
### Installation

```bash
git clone https://github.com/vile/on-chain-bonds.git
cd on-chain-bonds
make # clean, install deps, build
```

## Usage

See the [Static Analyzers](#static-analyzers) for external tool installation.


### Testing

Run all Founry tests, slither, and aderyn:

```bash
make test-ext
```

Run slitherin instead of slither:

```bash
make test-ext2
```

Run individual tests:

```bash
forge test --mt test_testName -vvvvv
```

### Deploying

TODO

### Static Analyzers

<details>
<summary><a href="https://github.com/crytic/slither?tab=readme-ov-file#how-to-install">Slither</a></summary>

```bash
python3 -m pip install slither-analyzer # OR
pipx install slither-analyzer
```

</details>

<details>
<summary><a href="https://github.com/pessimistic-io/slitherin?tab=readme-ov-file#installation-process">Slitherin</a></summary>

```bash
pip install slitherin
# OR
pipx install slitherin
echo -e "# Slitherin with pipx\nexport PATH=\"\$PATH:/home/$USER/.local/pipx/venvs/slitherin/bin\"\n" >> ~/.bashrc \
&& source ~/.bashrc
```

</details>

<details>
<summary><a href="https://github.com/Cyfrin/aderyn?tab=readme-ov-file#using-cargo">Aderyn</a></summary>

```bash
# Install rust if not installed already
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install aderyn
```

</details>

<details>
<summary><a href="https://github.com/Picodes/4naly3er">4n4lyz3r</a></summary>

Refer to repo usage steps.

</details>

## Known Issues

1. Bond instances are to not be used with [any weird ERC20s](https://github.com/d-xo/weird-erc20) (e.g., stETH (rebasing) or PAXG (fee-on-transfer)).
2. Ether can become locked forever in certain contracts if `value` is included with specific function calls.
3. Individual Bond instances (beacon proxies) are owned, users of each bond instance need to trust the owner.
4. NFTs are transferrable; the original bond purchaser (minter) and the recipient of an accepted bond's tokens may differ.
5. When creating proxies, NFT metadata (name, symbol, URI) is not validated or checked that it follows any convention.