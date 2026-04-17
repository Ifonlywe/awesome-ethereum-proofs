## Contract

| Field | Value |
|-------|-------|
| Address | `0x9e0ae8ffd946d12d1d393c6f3bca0eecadc9428e` |
| Deployed | Sep 17, 2015 (block 247,409) |
| Compiler | soljson-v0.1.1+commit.6ff4cd6 |
| Optimizer | ON |
| Runtime | 59 bytes |
| Creation | 76 bytes (17 bytes init) |
| Runtime SHA-256 | `29b8078741d0d667ecd7136847080bfcd2eb7c8bf398bc0355c025bf32e35094` |
| Creation SHA-256 | `cbc8f5b356bd5dfb62ddb77c40a6d5681aa746efd749a12b43e2d76ddc71200d` |
| Proved by | [@lecram2025](https://ethereumhistory.com/historian/lecram2025) |

## Notes

A minimal storage cell deployed by Thomas Bertani (Oraclize team) on September 17, 2015 — the earliest Bertani contract from this day's experimentation. At 59 bytes runtime, it is one of the smallest non-trivial Solidity contracts on Ethereum.

It exposes two functions: `set(uint256 x)` writes to storage slot 0, and `get()` reads slot 0 and returns it. The contract is the forwarding target for two sibling proxies deployed the same day: GetSet (`0x77beac0aed3b9e75ee2aba60b3dec66ff47e96c2`) and Controller (`0x3c94923400ccc528e8ab0f849edafca06fe332e5`), both of which call this contract's `set()` to write values into storage slot 0 here.

The source uses an explicit `function get()` returning the storage value, NOT the auto-generated `uint public get` syntactic sugar. The auto-getter version would compile to 64 bytes (5 bytes more) due to slight differences in the generated dispatch and return path.

## Verification

```bash
node verify.js
```

The script downloads soljson-v0.1.1, compiles `Target.sol` with optimizer ON, and compares the output byte-for-byte against the on-chain runtime and creation bytecode.
