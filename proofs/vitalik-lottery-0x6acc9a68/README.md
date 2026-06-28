# Vitalik's private contract (0x6acc9a68…) — Serpent

Deployed by Vitalik Buterin (`0x1db3439a22ee7c4d034e9b26437d3960b5af0517` / vitalik.eth)
on 2015-10-12. One of his most-used early contracts. **Written in Serpent, not Solidity.**

| Field | Value |
|-------|-------|
| Address | `0x6acc9a6876739e9190d06463196e27b6d37405c6` |
| Deployed | 2015-10-12 |
| Deployer | `0x1db3439a22ee7c4d034e9b26437d3960b5af0517` (Vitalik) |
| Runtime | 851 bytes |
| Language | **Serpent** (Vitalik's own language) |
| Function IDs | `9305414a`, `4ae00041` (Serpent ABI) |
| Status | **Decoded; Serpent source reconstruction pending** (needs the Oct-2015 serpent compiler) |

## Why this is Serpent, not Solidity

The bytecode is unmistakably Serpent-compiled:

- **Init marker** `600061027f53` — `PUSH1 0 PUSH2 0x027f MSTORE8`, Serpent's runtime
  length stamp, not Solidity's `6060604052`.
- **`5990590160009052` memory allocator** — `MSIZE DUP2 MSIZE ADD … MSTORE`, Serpent's
  signature dynamic-allocation idiom, repeated throughout. Solidity never emits this.
- **Raw `LOG1` with a literal 32-byte topic** `f7eba460ce397de720ba4749bd9c125fec27d45e
  f68e15fffe706e8c211a7f5c` — a hand-rolled Serpent `log` call, not a Solidity `event`.
- **Identity-precompile (`0x04`) calls** used for `mcopy`-style memory moves — Serpent's
  internal copy mechanism.

## Decoded behaviour

Two externally-callable functions (dispatched on a `PUSH29 / 2**224` selector mask):

- **`4ae00041`** — ABI-encodes the string `"cow"` (`636f77`) and `CALL`s another
  contract's `get(string)` (selector `693ec85e` — a name/registry lookup), then writes
  the returned value to storage (`SSTORE`, slot keyed by a mapping over the call args).
- **`9305414a`** — reads two storage slots, runs the args through the identity-precompile
  copy path, and emits the `LOG1` event with the `f7eba460…` topic.

So the contract is a small Serpent front-end over an external **`get("cow")` registry/
oracle** that records results into storage and logs them — consistent with a
commit/record style "private lottery" or registry helper.

## Reconstruction path (future work)

Byte-exact reproduction requires the **period Serpent compiler** (pyethereum
`serpent`, Sep–Oct 2015) — its codegen, ABI hashing, and the `5990590160009052`
allocator are version-specific and differ from the C++ `libserpent`. Solidity (any
version) provably cannot produce this bytecode. The on-chain runtime is preserved in
`target_runtime.txt` for that effort.
