# Partnership (Jamie Hale's DAO partnership template)

- **Address:** `0x12b0621d90c69867957a836d677c64c46ec4291d`
- **Deployer:** `0xd69104404a21cf359985c21988b959ace3880c83`
- **Deployment block:** 1,781,342 (2016-06-27 13:39:01 UTC, three days after the DAO hack began and three weeks before the Ethereum hard fork)
- **Runtime size:** 4,417 bytes
- **Balance (May 2026):** 12.00 ETH
- **Verification:** exact_bytecode_match

## Source

The contract is `Partnership` from `jamiehale/dao_partnership` at commit [`8d6b374ec5`](https://github.com/jamiehale/dao_partnership/blob/8d6b374ec5/contract.sol), the last commit before the deployment timestamp. Same-day commit history:

- `8d6b374ec5` Refactor to extract and tidy modifiers (2016-06-27 03:36 UTC)
- `8a34566973` Add support for withdraw pattern (2016-06-27 02:28 UTC)
- `f8c6697deb` Add activeTransactionCount public variable (2016-06-27 02:04 UTC)
- `3b134b0d05` Add cancelTransaction (2016-06-27 01:43 UTC)

## Verification

```
$ node verify.js
Runtime: 4417 bytes
Target:  4417 bytes
Runtime SHA-256: 8a2bdb0db955f942eb60d75d0dd36f5a3180431c55dbdde895bb968f27f9f5cb
Target  SHA-256: 8a2bdb0db955f942eb60d75d0dd36f5a3180431c55dbdde895bb968f27f9f5cb
VERIFIED: exact bytecode match
```

Compiler: `soljson-v0.3.2+commit.81ae2a78` (released 17 June 2016, the latest stable Solidity release on the deployment date), optimizer ON. The same bytecode also reproduces with v0.3.0 and v0.3.1 optimizer ON; v0.3.3 onward changed code-gen and produces 4,455 bytes.

## Story

An equal-share partnership pool. Each partner deposits `sharePrice` wei to buy in. Once all partners have paid, `funded` flips true and the partnership goes live. Partners propose transactions with `proposeTransaction(to, value, data, description)`, and every other partner must call `confirmTransaction(id)` before `executeTransaction(id)` will send. The contract supports proportional dividends via `distribute(addr, amount)` / `distributeEvenly(amount)`, partner loans (`repayLoan`), and a withdraw pattern via `withdrawableAmounts(addr)` / `withdraw(uint)`. `dissolve(addr)` lets the last living partner shut down and forward the remainder.

The deployer `0xd69104...` subsequently sent transactions to The DAO at `0xbb9bc244d798123fde783fcc1c72d3bb8c189413`, confirming this Partnership was used to pool ETH for a co-investment in The DAO. The 12 ETH stuck in the contract has been there since at least the DAO hard fork on 20 July 2016.

## Files

- `Partnership.sol` - source from jamiehale/dao_partnership@8d6b374ec5
- `target_runtime.txt` - on-chain runtime bytecode (4,417 bytes)
- `soljson-v0.3.2.js` - exact compiler binary used (commit 81ae2a78)
- `verify.js` - reproducer

## Author

Jamie Hale (`jamiehale` on GitHub), with contributions from `celeduc`. Repo: https://github.com/jamiehale/dao_partnership.
