# URLhint (EF Frontier registrar)

The Ethereum Foundation's `UrlHint` contract — part of the Frontier name/registrar
system, hardcoded into go-ethereum. It maps a content hash to a list of URL hints
(the "where do I fetch this contract's metadata" oracle). Paired with `HashReg` and
`GlobalRegistrar`, it was the proto-oracle/registry of the Frontier era.

| Field | Value |
|-------|-------|
| Address | `0x73ed5ef6c010727dfd2671dbb70faac19ec18626` |
| Deployed | 2015-09-24 |
| Significance | Hardcoded `UrlHintAddr` in go-ethereum (`common/registrar`) |
| Runtime | 193 bytes |
| Selector | `300a3bbf` = `register(uint256,uint8,uint256)` |
| Compiler | cpp-ethereum dev build, **pre-v0.1.1 (PoC-9 / ~v0.9.x internal, June 2015 era)** |
| Optimizer | ON (constant optimizer active) |
| Verification | `source_verified` — source is the EF's own published source; on-chain runtime is **byte-for-byte identical** to go-ethereum's hardcoded `UrlHintCode` |
| Proved by | [@cartoonitunes](https://ethereumhistory.com/historian/cartoonitunes) |

## Provenance (strongest class)

This is not a reconstruction — the source is the EF's **own published source**:

- `URLhint.sol` is `UrlHintSrc` from go-ethereum `common/registrar/contracts.go`
  (the comment in that file drops the word `mapping` on the `url` line; it is restored
  here — it does not affect bytecode).
- The on-chain runtime equals the **runtime slice of `UrlHintCode`** (the hex string
  compiled into every go-ethereum binary) byte-for-byte:

```
runtime (193 B):
60003560e060020a90048063300a3bbf14601557005b6024600435602435604435602a565b
60006000f35b6000600084815260200190815260200160002054600160a060020a0316600014
806078575033600160a060020a03166000600085815260200190815260200160002054600160
a060020a0316145b607f5760bc565b336000600085815260200190815260200160002081905550
806001600085815260200190815260200160002083610100811060b657005b01819055505b
50505056
```

## Compiler analysis

The dispatcher uses the *pre-v0.1.1* shape: `CALLDATALOAD 2**224 SWAP1 DIV DUP1`
(`60003560e060020a90048063…14`) — note there is **no `6060604052` free-memory-pointer
preamble** (that landed with "Dynamic memory", cpp-ethereum `e663839`, 2015-06-09).
Both the selector mask `2**224` and the address mask `2**160-1` are emitted as
**EXP forms** (`60e060020a`, `600160a060020a03`) rather than `PUSH29`/`PUSH20`
literals — this is the **"Compute constants" optimizer** (cpp-ethereum `3fc61e9`,
2015-06-05).

This pairing — *old CALLDATALOAD-first dispatcher codegen* **plus** *the new constant
optimizer* — does not coexist on any single mainline cpp-ethereum commit (mainline had
already switched the dispatcher to the `2**224 CALLDATALOAD DIV DUP2` shape by the time
the constant optimizer merged). The EF compiled the registrar contracts at a transitional
local/branch snapshot. A native cpp-ethereum solc built from the June-2015 tree
(`9db5fb5`) reproduces the EXP-mask constant forms and identical contract logic; the
exact dispatcher byte-arrangement reflects that pre-release snapshot. See `verify.js`.

No published solc binary predates v0.1.1 (binaries.soliditylang.org starts there; npm
`solc` at 0.1.3), and Sourcify's oldest supported compiler is v0.1.7 — so this contract
cannot be machine-verified on Sourcify/Etherscan. The go-ethereum source+bytecode pair
is the canonical, authoritative proof.

## Verify

```bash
node verify.js   # fetches on-chain runtime, diffs against go-ethereum UrlHintCode
```
