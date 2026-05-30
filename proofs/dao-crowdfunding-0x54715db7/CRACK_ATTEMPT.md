# DAO Crowdfunding crack attempt notes

## Address
0x54715db7a8a57bc9bab660eb8e7b195774cb564d (deployed 2015-12-29 17:33 UTC)

## Result: NOT cracked

Closest compile is byte-length 6245 vs target 6244, with first divergence at byte 172.

## Setup tried

- Source: `Token.sol`, `Crowdfunding.sol`, `DAO.sol` from blockchainsllc/DAO commit b7aeb4e654
  (latest commit at time of deployment, only 3 minutes after the deploy tx)
- Concatenated single-source compile (imports stripped)
- Tested solc versions: 0.1.5 through 0.3.6
- v0.1.5 fails (no `.push()` on address[] in this version)
- v0.1.6 / v0.1.7 with optimizer enabled both produce 6245 bytes (target 6244)
- v0.2.x produces 6247, v0.3.0-0.3.2 produces 6250, v0.3.3+ produces 6291

## Also tried

Pulling intermediate DAO.sol from earlier commits 95d85c6f48, 90a14073a3, 52b0a0f88a, b2cad2182f.
All these earlier commits produce bytecodes with cp=18 (only the prelude matches), meaning the
contract structure was different prior to b7aeb4e654.

## Diff analysis

Using difflib.SequenceMatcher on byte arrays of v0.1.6 opt=1 output vs target:

- mine = 6245 bytes, target = 6244 bytes (net +1 byte)
- First divergence at byte offset 172
- Total of 31 diff regions
- Most diffs are 1-2 byte shifts in jump destinations (cascade from one root cause)
- 261-byte function appears at offset 3028 in mine but at offset 5795 in target (function reorder)
- 2-byte `5190` (MLOAD SWAP1) extra at offset 1591 in mine, 1-byte `51` (MLOAD) extra at 1595 in tgt (net +1)
- Four `0f`/`03` byte pair swaps in inline assembly for sha3 padding

## Likely cause

The actual deployed source likely had:
1. Functions in a different order than the GitHub source (one function moved to the end)
2. A slightly different `sha3(_recipient, _etherAmount, _transactionBytecode)` inline-asm pattern
   that the compiler emits a few bytes differently for

The compiler is correct (v0.1.6) but the source is not byte-identical to what was deployed.
This is a case where a local edit was made before deployment that never landed in the public repo.

## What would crack it

Either:
- A snapshot of the local source at deployment time (not available in git)
- Trying every possible function permutation in the source (24! is too many)
- A custom solc binary that matches whatever local build was used (unlikely - public soljson works)
