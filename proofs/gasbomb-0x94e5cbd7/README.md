# Gas-bomb / tarpit benchmark contract

- **Address:** `0x94e5cbd7971d360b21804ea721bb68f01c326f11`
- **Deployer:** `0x0e95adb39a2dfe1c8f3969de4480a5d3ddfadebd`
- **Deployment block:** 2,853,596 (2016-12-22 06:36:03 UTC)
- **Runtime size:** 2,626 bytes
- **Balance (May 2026):** 2 wei
- **Verification status:** synthetic contract; no meaningful source to recover

## Identification

47 dispatched selectors, none resolve in openchain or 4byte. The contract's structure is unusual:

- 41 of 47 dispatched functions are empty stubs that execute `JUMPDEST JUMPDEST JUMP` (`5b5b56`) and do nothing.
- The function at selector `0x6915a0b0` contains a manually-unrolled inner loop: the byte pattern `38 60 00 83 39 38 82 01 91 50` (`CODESIZE PUSH1 0 DUP4 CODECOPY CODESIZE DUP3 ADD SWAP2 POP`) appears 100 times in a row, each iteration self-copying the entire runtime bytecode into memory. This is a deliberate gas-burner.
- Two functions (`0x338ee81d` and one other) push opaque constants and emit a single log topic `0xe54f769b9353d01325533f18da3a888c3316c2fbb1414cbede1899b6ad5ea2db` as a beacon.
- Deployer transactions show calls to the contract with full gas-limit (~3.5M) that consumed the full limit and reverted, consistent with someone probing gas-cost behaviour.

## Context

Deployed 22 December 2016, one month after the Spurious Dragon hard fork (block 2,675,000, 22 November 2016). Spurious Dragon's centerpiece was EIP-150 / EIP-160 / EIP-170 gas-cost repricing for memory-heavy and `SLOAD`/`SUICIDE`-related opcodes, introduced to mitigate the September-October 2016 DoS attacks against Geth and Parity nodes. The 100-times-unrolled CODECOPY loop here is exactly the kind of synthetic stress test a researcher would build to benchmark client behaviour after the repricing.

The GEMS-MASTER hunt initially flagged this as the "best decompilation candidate" because it has 48 unique selectors that don't resolve. The selector count was real but misleading: the high uniqueness reflects synthetic empty-stub functions, not a rich application surface. There is no Solidity source to recover.

## Files

(no source files; this folder exists only as documentation of the identification.)

## References

- Etherscan: https://etherscan.io/address/0x94e5cbd7971d360b21804ea721bb68f01c326f11
