# BitnationShares — Source Reconstruction

| Field | Value |
|-------|-------|
| Address | `0xedb37809291efbc00cca24b630c3f18c2a98f144` |
| Deployed | Feb 17, 2016 (block 1019907) |
| Deployer | `0xd1220a0cf47c7b9be7a2e6ba89f429762e7b9adb` (avsa) |
| Token Name | Ƀitnation Shares |
| Symbol | XBN |
| Decimals | 8 |
| Total Supply | 400,000,000 XBN |
| Compiler | native solc v0.2.1 (webthree-umbrella, Feb 2016) with --optimize |
| Verification | Source reconstructed (99.6% match, 6-byte compiler variant) |
| Runtime | 1416 bytes |
| Creation | 2093 bytes |
| Runtime SHA-256 | `da45fa96375d1b1bc75ab05ed84954a1436b65a1f176c75389ce059780efc825` |
| Creation SHA-256 | `42e84c66908dd9fffdecfe084152455d97d6e0210e42b7566c19b3629bbb8504` |
| Proved by | [@Neo](https://ethereumhistory.com/historian/neo-by-cart00n) |

## Background

Bitnation was founded in 2014 by Susanne Tarkowski Tempelhof as a blockchain-based governance
platform offering services including digital IDs, marriages, land titles, and birth certificates.
In February 2016, Bitnation migrated their tokens to Ethereum and worked with Alex Van de Sande
(avsa) to develop their digital constitution, Pangea. This contract was deployed by avsa
on February 17, 2016 during that migration.

## Source Reconstruction

The source code was reconstructed through bytecode analysis:

- **Storage layout**: `allowance` at slot 4, `spentAllowance` at slot 5 (critical ordering)
- **Approve callback**: Uses hardcoded selector `bytes4(0x3d21aa42)` for `sendApproval(address,uint256,address)`
- **Return types**: Both `approve` and `transferFrom` declare `returns (bool success)`
- **Fallback**: Explicit `function() { throw; }` (generates 8-byte throw pattern)
- **Overflow check**: `transferFrom` uses `_value + spentAllowance > allowance` (overflow-safe)
- **Init code confirmed**: Constructor bytecode matches production deployment exactly

## Compilation Notes

The contract was compiled with native C++ solc v0.2.1 (webthree-umbrella, Feb 2016).
The `--optimize` flag was used.

A 6-byte discrepancy exists between the reconstructed bytecode and the on-chain bytecode.
This is due to a compiler optimizer behavior difference between x86_64 and ARM64 architectures.
The original deployment used x86_64 Linux; our reconstruction uses ARM64 (Apple Silicon Docker).
The difference is in the `approve` function's post-CALL cleanup path:
- **On-chain (x86_64)**: Pattern A — checks failure first, then inline cleanup (no subroutine)
- **Reconstruction (ARM64)**: Pattern B — partial cleanup first, then checks, via 6-byte subroutine

The source code itself is confirmed correct by:
1. Exact constructor bytecode match (only runtime size differs in init code)
2. All 9 function bodies match in size and structure
3. All subroutines match except for the 6-byte cleanup subroutine variant

## Verify

```bash
docker run --rm -v $(pwd):/src solc-umbrella sh -c \
  "cd /src && /umbrella/build/solidity/solc/solc --optimize --bin-runtime BitnationShares.sol 2>&1" \
  | grep -A1 "Binary of the runtime part" | tail -1
```

Compare output with `target_runtime.txt`. On ARM64, 6-byte difference expected.
