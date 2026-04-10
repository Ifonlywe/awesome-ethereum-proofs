# AdminCheck -- Bytecode Verification Proof

| Field | Value |
|-------|-------|
| Address | `0x49efab3940f7e47e2ef564be865e492fd482c595` |
| Deployed | Dec 30, 2015 (block 732,572) |
| Compiler | soljson v0.1.6+commit.d41f8b7c |
| Optimizer | ON |
| Runtime | 147 bytes |
| Creation | 163 bytes (16 bytes init, no constructor args) |
| Runtime SHA-256 | `a8cd44e9a0cf12f77fa9204f4533dc3e3e8d6ec2b6ede20cd364bc36a2f9df97` |
| Creation SHA-256 | `732aa4d6d853a1b1d97e9d5502448de14c650086f1e74a1f138ba588fef10425` |
| Proved by | [@lecram2025](https://ethereumhistory.com/historian/lecram2025) |

## Contract

An admin-check test contract with three functions: `kill()` to selfdestruct, `get()` to return the owner address (always zero since no constructor sets it), and `test()` which returns true if the caller matches a hardcoded admin address (`0x8b9346aa...`).

Part of a series of iterative prototypes by deployer `0x8b9346aa...`, who deployed over 400 contracts between December 2015 and May 2016. This is the second step in their progression after a simple key-value Store contract. The hardcoded address comparison pattern seen here became a core feature of their later multi-party escrow contracts.

The contract was selfdestructed shortly after deployment.

## Verification

```bash
node verify.js
```

The script downloads soljson-v0.1.6, compiles `AdminCheck.sol` with optimizer ON, and compares the output byte-for-byte against the on-chain runtime and creation bytecode.
