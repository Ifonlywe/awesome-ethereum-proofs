# Frontier-week hash-bidding puzzle

- **Address:** `0x35e57f2b08596f1946ecd9d31975ec3c2d7e1c1d`
- **Deployer:** `0x0e320219838e859b2f9f18b72e3d4073ca50b37d`
- **Deployment tx:** `0x22a876e8958a6a1905aaa743eaef9c2ab4a832f949bc556e458b399e202279b6`
- **Block:** 75,971 (2015-08-12 04:52:38 UTC)
- **Runtime size:** 2,152 bytes
- **Balance (May 2026):** 0.106 ETH
- **Verification status:** source_reconstructed (no matching source found)

## Identification

Contract identified by ABI selector decode against openchain.xyz. 12 of 13 selectors resolve:

| Selector | Function |
|----------|----------|
| 0x0bf94512 | submitSolution(uint256) |
| 0x15df48bc | getBidderAt(uint256) |
| 0x200d2ed2 | status() |
| 0x3ff0d535 | getCompetitionEnd() |
| 0x409a967f | getHashAt(uint256) |
| 0x44b5f535 | (unresolved) |
| 0x5209ea57 | blockToHash() |
| 0x9391a16a | getBidAt(uint256) |
| 0x947a36fb | interval() |
| 0x9db6537d | bonusFund() |
| 0xc0336629 | setStatus() |
| 0xc2afd8c6 | getNumBids() |
| 0xe2543d1c | newBid(uint256) |

## Behaviour inferred from selectors and bytecode

A hash-prediction game with bid-and-solve mechanics:

1. Players call `newBid(uint)` to commit a guess at a future block's hash. Bids are appended to an enumerable array (`getNumBids`, `getBidAt`, `getBidderAt`, `getHashAt`).
2. `blockToHash()` returns the target block whose hash the solution must match.
3. Rounds advance through phases tracked by `status()` / `setStatus()`. `interval()` returns the round length; `getCompetitionEnd()` returns the cutoff block.
4. `submitSolution(uint)` is called once the target block is mined to claim the `bonusFund()` prize.

## Deployer activity

The deployer self-seeded the game in the first hour after deployment:
- Block 75,971: deployment (0.1 ETH funding)
- Block 75,979: 0.005 ETH top-up
- Block 75,997: `newBid(...)`
- Block 76,017: `setStatus()`
- Block 76,042: `setStatus()`
- Block 76,283: `newBid(...)`

The deployer's tx history (blocks 48679/48687) shows two earlier sends to Kraken's hot wallet at `0x2910543af39aba0cd0` with deposit tag `ENNX1N6W0`.

## Next steps for a full crack

- Decompile with Heimdall or Panoramix to recover storage layout.
- Compile candidates with solc v0.1.x docker images at `/Users/claw/.openclaw/tools/` and compare runtime bytecode.
- Try `0x44b5f535` against common 2015 method names (`expire()`, `dispute()`, `claim()`).

## References

- Etherscan: https://etherscan.io/address/0x35e57f2b08596f1946ecd9d31975ec3c2d7e1c1d
- Deployment tx: https://etherscan.io/tx/0x22a876e8958a6a1905aaa743eaef9c2ab4a832f949bc556e458b399e202279b6
