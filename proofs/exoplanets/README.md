# ExoPlanets

ERC-721 hot-potato NFT game in the CryptoCelebrities fork family. Players buy exoplanets at escalating prices.

| Field | Value |
|-------|-------|
| Address | `0xB41FeA87Ef7cf3275c55A6F92d0C95C0F8F6198F` |
| Deployed | Jun 28, 2018 (block 5,870,490) |
| Deployer | `0x76990237ea27b27e598c3923fbc8ebb52a01e394` |
| Compiler | soljson v0.4.18+commit.9cf6e910 |
| Optimizer | OFF (runs=200) |
| Runtime | 17,726 bytes |
| Creation | 17,940 bytes |
| Runtime SHA-256 (on-chain) | `fe9b6e75c644a2300a21ec7bed98534625076093b1c6c998020cbcefbba6cc90` |
| Verification | `source_reconstructed` — 25 of 17,694 non-metadata bytes still differ (99.86% non-metadata match) |
| Proved by | [@cartoonitunes](https://ethereumhistory.com/historian/cartoonitunes) |

## Verification

```bash
# 1. Fetch the on-chain runtime
curl -s "https://api.etherscan.io/v2/api?chainid=1&apikey=YOUR_KEY&module=proxy&action=eth_getCode&address=0xB41FeA87Ef7cf3275c55A6F92d0C95C0F8F6198F&tag=latest" | \
  python3 -c "import sys,json; print(json.load(sys.stdin)['result'][2:])" > onchain_runtime.txt

# 2. Compile ExoPlanets.sol with solc v0.4.18, optimizer OFF
# (use solcjs or any soljson-v0.4.18+commit.9cf6e910.js wrapper)
# Settings: optimizer.enabled=false, outputSelection includes deployedBytecode

# 3. Diff the compiled output against on-chain
# Size matches exactly at 17,726 bytes.
# 57 bytes differ in total: 32 in the trailing bzzr0 metadata hash (always different
# unless you recover the exact source file used at deploy time) and 25 bytes inside
# the runtime code itself.
```

## Residual gap (25 non-metadata bytes)

The remaining differences cluster in three regions that resisted all source-level permutations:

1. **PC 15563–15613, 15616, 15621 (~18 bytes)** — Inside an internal string-copy
   helper invoked from `getExoplanet`. The compiler emits the equivalent operations
   in a different order (allocate-then-call vs call-then-allocate) and selects between
   two functionally-identical 19-byte string-allocator helpers (`0x41e2` and `0x43bc`)
   in a different sequence for the chained 6-string allocation dispatch.

2. **PC 15672, 15681 (2 bytes)** — `DUP7` vs `DUP6` inside the same string-copy
   helper. 1-level stack depth difference.

3. **PC 16252, 16365–16368 (5 bytes)** — Code-motion difference in an alloc-helper
   epilogue: mine emits `JUMP; JUMPDEST; DUP1; SWAP1; POP; JUMPDEST; SWAP2; SWAP1;
   POP; JUMP; JUMPDEST`, on-chain emits `JUMP; JUMPDEST; JUMPDEST; DUP1; SWAP1; POP;
   SWAP2; SWAP1; POP; JUMP; JUMPDEST`. The earlier `PUSH2` target adjusts by 3 bytes
   to reach the same final label.

These are deterministic compiler choices in the string-helper instruction scheduler
that no source-level rearrangement of struct field order, return order, expression
order, or local declaration order reaches.

## Cracks closed during reconstruction

Three source patterns moved the match from 99.49% down to 99.86%:

1. **`purchase()` local declaration order.** Moving `address oldOwner` from the
   *first* declared local to the *last*, and swapping `multiplier`/`fee` so `fee` is
   declared earlier, aligned the entire price-tier `SWAP`/`DUP` chain (32 bytes)
   plus the post-cascade `mul/div`/`oldOwner = currentOwner[_tokenId]` reads
   (5 bytes).

2. **`Birth` event 3rd argument.** The source passes
   `_numOfTokensBonusOnPurchase` (uint32) rather than `_priceInExoTokens` (also
   uint32) as the `lifeRate` slot of the Birth event. Both compile; the on-chain
   bytecode `DUP8` instead of `DUP10` revealed which parameter was actually wired
   in. This closed the 1-byte gap at PC 14631.

3. **Compiler/optimizer settings.** `solc v0.4.18+commit.9cf6e910` with optimizer
   *off* (runs=200 setting retained from standard JSON input) and standard JSON
   compilation. The pragma `^0.4.18` and matching commit hash are required.

## Storage layout

`exoplanets` array at slot 7. Per-element struct (each new index reserves 9 slots):

```
slot 0  uint8  lifeRate
slot 1  uint32 priceInExoTokens
slot 2  uint32 numOfTokensBonusOnPurchase
slot 3  string name
slot 4  string cryptoMatch
slot 5  string techBonus1
slot 6  string techBonus2
slot 7  string techBonus3
slot 8  string scientificData
```

Other slots: `currentOwner` mapping at 0, `ownershipTokenCount` at 1, `tokenApprovals` at 2, `exoplanetIndexToPrice` at 3, `ceoAddress` at 4, `cooAddress` (+ packed bool `paused` at byte 20, packed bool `inPresaleMode` at byte 21) at 5, `newContractAddress` at 6.

## Function signatures recovered

Notable selectors confirmed via OpenChain lookup:

- `createContractExoplanet(string,uint256,uint32,string,uint32,uint8,string)` → `0x1d8b4dd1` (not the more obvious `(string,uint256,uint8,uint32,uint32,string,string)` ordering)
- `purchase(uint256)` → `0xefef39a1`
- `getExoplanet(uint256)` → `0x06d91eea`

## Files

- `ExoPlanets.sol` — reconstructed source (single file with inline `SafeMath` library)
- `target_runtime.txt` — on-chain runtime hex (17,726 bytes)
