# Tiny Human - Imogen Heap on-chain royalty splitter (BlockApps + Mycelia)

- **Address:** `0xc7696b27830dd8aa4823a1cba8440c27c36adec4`
- **Deployer:** `0x421291621428555e77f5ad58f217c9efa84d901f` (BlockApps)
- **Deployment tx:** `0x9b5615d7abef6660e3d9941add9f0284e3428021339095261d35a8ac857506b6`
- **Block:** 319,299 (2015-10-01 22:26:28 UTC)
- **Runtime size:** 5,673 bytes
- **Balance (May 2026):** ~104,000 wei (dust)
- **Crack status: NOT cracked.** No serious reconstruction attempted, see `CRACK_ATTEMPT.md`. Palkeoramix decompile (33-line stub) is available.

## Identification

This is the royalty-splitter smart contract used for Imogen Heap's "Tiny Human" release on her Mycelia platform in October 2015. By total revenue ($133.20 by 2017, per Wikipedia), it was modest, but historically it stands as the first commercial music release whose royalties were settled by an Ethereum smart contract. BlockApps built the contract infrastructure under Mycelia's branding.

The decompiled selector surface matches a per-stem royalty splitter:

- `TOTALSHARES()` `shares(bytes32, bytes32)` `ownersCount()` `owners(uint256)` - share registry per beneficiary
- `BOARD_1()` `BOARD_2()` `BOARD_3()` `admin()` `changeAdminFromBoard(address)` `setNewAdmin(address)` - 3-of-N board governance
- `BLOCKAPPS()` `setBlockappsAddr(address)` - BlockApps service address
- `oracle()` `setNewOracle(address)` `usdEthPrice()` `priceLastUpdated()` - off-chain ETH/USD price feed
- `USDDOWNLOADPRICE()` `downloadPriceInWei()` `USDSTEMPRICE()` `stemPriceInWei()` `setPrice(uint256)` - dual pricing (full track vs. individual stem)
- `purchase(bytes32)` - main customer entry point: pay for a track or stem
- `transferRightIfApproved(address, bytes32)` - reassign ownership of a purchased right
- `transferCount()` `transferLog(uint256)` `txCount()` `txLog(uint256)` - on-chain audit log
- `setAddr(uint256, address)` - admin setter for beneficiary wallets

## Stem contributors (hardcoded in constructor)

The contract's constructor encodes the names of the eight credited collaborators on "Tiny Human":

- Imogen Heap
- Stephanie Appelhans
- Diego Romano
- Yasin Gundisch
- Hoang Nguyen
- Simon Minshall
- David Horwich
- Simon Heyworth

Each name has a corresponding share weight, and `purchase(bytes32)` splits the incoming payment proportionally.

## Why so little ETH

The contract's life-to-date revenue is tiny because the front-end pricing was in USD with stems at low single-digit prices and downloads at low double-digit prices. Total earnings are consistent with the publicly-reported $133.20 across ~2 years.

## Crack attempt result (NOT cracked)

No serious reconstruction attempted. Palkeoramix failed on 30 of 33 functions. Reconstructing 5,673 bytes of bytecode for 33 functions (custom royalty-splitting with 8 hardcoded contributors, USD pricing oracle, 3-of-N board governance, per-stem purchase tracking) from scratch is multi-day effort. What would close it: BlockApps archive recovery, or a 0.1.x-aware decompiler that succeeds where Palkeoramix fails.

## Files

- `decompile_palkeoramix.txt` - Palkeoramix decompile (Palkeoramix failed on 30/33 functions; the rest pass through as raw assembly)
- `CRACK_ATTEMPT.md` - notes on why no full reconstruction was attempted

## References

- Wikipedia: Imogen Heap (Mycelia section)
- BlockApps STRATO platform: https://blockapps.net
- Mycelia for Music: https://myceliaformusic.org (Imogen Heap's project)
- Decompile source: https://github.com/mkeresty/ethereum_archeology
