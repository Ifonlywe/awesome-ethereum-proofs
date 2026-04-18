# KingOfHill Contract Verification

"King of the Hill" bidding game: players send ETH to claim the throne. If no one bids for 600 seconds, the last bidder can claim the balance via `suicide`. Sending exactly 0.000123 ETH triggers an emergency self-destruct to the sender.

## Contract

| Field | Value |
|-------|-------|
| Address | `0x465b83e4b4c0294bf6d374d4733b95bb150bd21c` |
| Deployed | 12 Aug 2015 2015 (block 73713) |
| Compiler | soljson-v0.1.1+commit.6ff4cd6 |
| Optimizer | ON |
| Runtime | 299 bytes |
| Creation | 371 bytes (72 bytes init + 299 bytes runtime) |
| Runtime SHA-256 | `51fcfd3b42f88279813720ea7c3d4e7dbc979ca90fb7eef54963e8bc003433b9` |
| Creation SHA-256 | `64787c6b02b631e2d5182899ed2b661e0be3d2c48424cbff402abfe669d28325` |
| Proved by | [@gpersoon](https://www.ethereumhistory.com/historian/169) |

## Details

| Field | Value |
|-------|-------|
| Functions | `getLastAddress()`, `getFunder()`, `getRemainingTime()`, fallback (bid) |
| Constructor args | none |
| Pattern | King of the Hill bidding game with time-based claim and emergency kill code |

## Verification

    node verify.js

Downloads soljson v0.1.1, compiles `KingOfHill.sol` with the optimizer ON, and compares the resulting creation and runtime bytecode (byte-for-byte and SHA-256) against the on-chain bytecode in `target_runtime.txt`. Optionally fetches the deployment transaction from Etherscan for an additional on-chain check.
