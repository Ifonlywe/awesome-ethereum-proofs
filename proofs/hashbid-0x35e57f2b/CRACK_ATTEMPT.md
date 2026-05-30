# Hash-bid puzzle crack attempt notes

## Address
0x35e57f2b08596f1946ecd9d31975ec3c2d7e1c1d (deployed 2015-08-12 04:52 UTC)

## Result: NOT cracked

Closest reconstruction is 816 bytes vs target 2152 bytes. cp=59 (only first 59 bytes match,
which is just the boilerplate prelude and dispatch start).

## Setup tried

Reconstruction at `/tmp/work/fb/frontier_attempt1.sol` with these elements based on selector
decoding:
- `interval`, `bonusFund`, `competitionEnd`, `status`, `blockToHash` storage variables
- `Bid` struct array with `bidder`, `amount`, `hashAttempt`
- `newBid(uint)`, `getBidderAt(uint)`, `getBidAt(uint)`, `getHashAt(uint)`, `getNumBids()`
- `submitSolution(uint)` (body unknown - just left as stub)
- `setStatus()` (body unknown - guessed at `status += 1`)
- `getCompetitionEnd()` getter

Tested solc 0.1.1 through 0.1.7 (the only versions available before deployment date).
v0.1.1 and v0.1.2 do not load/compile in node (asm.js issues). v0.1.3-0.1.7 compile but
all produce ~816 bytes with optimizer, far short of target 2152.

## Selectors

All 13 selectors decode except `0x44b5f535`. The unknown selector body at offset 0x015e
reads from storage at `address+0x036b6384b5eca791c62761152d0c79bb0604c104a5fb6f4eb0703f3154bb3db3`
(a deterministic per-index storage slot), so it likely returns a stored value indexed by an argument.

## What would crack it

- Find the deployer's GitHub or other archives
- Spend several hours on a careful bytecode-driven reconstruction of all 13 functions
- This is a custom contract by an unknown author and was never published, so the only
  feasible route is full hand-decompilation
