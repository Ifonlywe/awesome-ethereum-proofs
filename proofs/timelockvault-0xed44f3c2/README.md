# TimeLockVault

A 2015 time-lock vault: send ETH to lock it for a fixed `duration` (≈20 years); send a
0-value transaction (or call `withdraw()`) to take it back once the lock expires. One
active lock per address — depositing again while you already have a balance just refunds
the new deposit. Famous in Ethereum lore for the long lock and a sizeable balance.

| Field | Value |
|-------|-------|
| Address | `0xed44f3c2081480b08643fe1ca281fab9ed643735` |
| Deployed | 2015-12-20 |
| Runtime | 433 bytes |
| Selectors | `0fb5a6b4` `duration()`, `3ccfd60b` `withdraw()`, `5e5c06e2` `accounts(address)` |
| Storage | `accounts` (mapping → `{balance, unlockTime}`) @ slot 0; `duration` @ slot 1 |
| Compiler | soljson **v0.1.3 – v0.2.0**, optimizer ON (identical output across that range) |
| Verification | `source_reconstructed` — 433/433 bytes, exact body order, **12 of 14 function bodies byte-identical** |
| Proved by | [@cartoonitunes](https://ethereumhistory.com/historian/cartoonitunes) |

## Match status

`TimeLockVault.sol` compiled with solc v0.1.7 (optimizer ON) produces **433 bytes —
exactly the on-chain length** — with the **same physical function-body layout** and
**12 of the 14 internal code blocks byte-for-byte identical**, including the full
dispatcher, `duration()`, `withdraw()` (all three `&&` guard clauses and the send/zero
sequence), the `accounts()` getter, the deposit-refund branch, and both ABI return
helpers.

### Residual (2 unmatched blocks, ~3 opcodes)

The only divergence is in the fallback's deposit path. The original compiler's optimizer
keeps the cached balance local `b` and a hoisted zero **alive on the stack** and reuses
them (via `DUP`) as the mapping's slot-0 constant in the keccak and as the struct's `+1`
field offset; every available 2015–2016 build (soljson v0.1.3–v0.3.0 plus the Dec-2015 /
Jan-2016 nightlies, which are byte-identical to the native C++ builds) instead consumes
those zeros and re-pushes them. This is a pure stack-scheduling / constant-CSE artifact
of the exact original build — it does not change semantics, length, or body order, and
no source-level permutation (96+ tried) reaches it. It is the same class of "optimizer
schedule" wall documented on other cracks in this repo.

The reconstructed source is semantically exact: the famous withdraw guard is
`balance > 0 && unlockTime > 0 && now > unlockTime` (byte-matches the chain).

## Verify

```bash
node verify.js   # compiles with soljson v0.1.7 and reports body-level match vs on-chain
```
