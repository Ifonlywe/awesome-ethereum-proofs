# CoinFlipper Contract Verification

A coin-flipping gambling contract: on each call, records `block.timestamp` in a public `flip` variable, and if the timestamp is odd, sends back twice the `msg.value`. A `donate()` function accepts ETH without payout, and a guard rejects bets larger than half the contract balance.

## Contract

| Field | Value |
|-------|-------|
| Address | `0xb87824547db80f1fb37d0225b99f1a602f8642ad` |
| Deployed | 08 Aug 2015 2015 (block 55627) |
| Compiler | soljson-v0.1.1+commit.6ff4cd6 |
| Optimizer | ON |
| Runtime | 169 bytes |
| Creation | 186 bytes (17 bytes init + 169 bytes runtime) |
| Runtime SHA-256 | `758902675e15219b879128d3357ab14b2ea9692b012b4794b2fc93b6ded6ace8` |
| Creation SHA-256 | `291ab047dc651564f4b237a3bd7768fde37a251e174f8f2fa8695ed2ccd373e9` |
| Proved by | [@gpersoon](https://www.ethereumhistory.com/historian/169) |

## Details

| Field | Value |
|-------|-------|
| Functions | `flip()` (auto-getter), `donate()`, fallback |
| Constructor args | none |
| Pattern | Timestamp-parity coinflip with balance guard and donate() |

## Verification

    node verify.js

Downloads soljson v0.1.1, compiles `CoinFlipper.sol` with the optimizer ON, and compares the resulting creation and runtime bytecode (byte-for-byte and SHA-256) against the on-chain bytecode in `target_runtime.txt`. Optionally fetches the deployment transaction from Etherscan for an additional on-chain check.
