# ReplayProtection (avsa ETH/ETC splitter, July 2016)

- **Address:** `0x64668c59ef8d480f3e832640a75566169a456541`
- **Deployer:** `0xd1220a0cf47c7b9be7a2e6ba89f429762e7b9adb` (Alex Van de Sande / avsa)
- **Deployment tx:** `0xee0ac70c52512276d9da1899c52564d7e9f7c5083654216b754840f67ec50552`
- **Block:** 1,959,092 (2016-07-27 02:34:24 UTC)
- **Runtime size:** 532 bytes
- **Runtime SHA-256:** `a6e5ae070945319e9e945dd8bb0cfe9ededeef0ee1453dbfc25600244fec04be`
- **Balance (June 2026):** 0 ETH
- **Crack status: CRACKED.** Compiled source produces a byte-for-byte runtime match with the on-chain code.

## Identification

This is one of Alex Van de Sande's replay-protection splitters from the week after the DAO hard fork (the fork that split the chain into ETH and ETC on 2016-07-20). The contract lets a caller route ether or an ERC20 token to one recipient on the main chain and a different recipient on the other fork, so a single signed transaction does not accidentally replay value across both chains.

The deployer (`0xd1220a…`, avsa) created several sibling `ReplayProtection` contracts in this window. Two are verified on Etherscan and share the exact dispatch idiom, compiler, and contract name:

- `0x181eec6b050ac30dff0c8b258ba0695339766734`
- `0xbf885158a5230dd185c9db354b1ea491c53bceb3`

Both verified as `ReplayProtection`, compiler `v0.3.5-2016-07-21-6610add`, optimizer 200.

### Public selectors

- `chainSignature()` -> `0x6c82a2ef` (public `bytes32`, storage slot 0)
- `etherSplit(address,address,bytes32)` -> `0x4aea5a21`
- `tokenSplit(address,address,address,uint256,bytes32)` -> `0xf253fdce`
- fallback `function () { throw; }`

## How this variant differs from the verified siblings

The verified siblings store a `bool isMainChain`, computed in the constructor by scanning the last 63 blockhashes for a known main-chain blockhash. This deployment is a later variant of the same source. Instead of a boolean, its constructor stores the matching blockhash into `bytes32 public chainSignature`, and the two split functions take a caller-supplied `_chainSignature` and branch on `chainSignature == _chainSignature` (main chain) versus `!=` (the other fork), keeping the original two-branch `if / else if / throw` shape.

The constructor scans `block.blockhash(block.number - i)` for `i` in `1..63` against the hardcoded main-chain blockhash `0xcf9055c648b3689a2b74e980fc6fa27817622fa9ac0749d60a6489a7fbcfe831`.

## Crack: exact bytecode match

Compiling `ReplayProtection.sol` in this directory with `soljson-v0.3.5+commit.5f97274a` (optimizer ON) produces a runtime whose SHA-256 equals the on-chain SHA-256:

```
a6e5ae070945319e9e945dd8bb0cfe9ededeef0ee1453dbfc25600244fec04be
```

The v0.3.3 and v0.3.4 releases produce the identical runtime under optimizer ON; v0.3.5 is canonical because it matches the deployer's verified siblings (compiled with the `v0.3.5-2016-07-21` nightly off the same release series).

### The byte-level discriminators

Two source details had to be exact for the bytecode to match:

1. **`.send()` not `.call.value()()`.** `etherSplit` forwards ether with `recipient.send(msg.value)`, which compiles to a gas-capped `CALL`. The `recipient.call.value(msg.value)()` form forwards all remaining gas and emits 3 extra bytes, so it was ruled out by the byte diff.
2. **A trailing `bytes32 _chainSignature` argument** on both split functions, recovered by keccak-matching the on-chain selectors `0x4aea5a21` and `0xf253fdce`. `tokenSplit` additionally requires `msg.value == 0` and builds an ERC20 `transferFrom(msg.sender, recipient, amount)` (selector `0x23b872dd`) forwarding `gas - 0x61da`.

Run `node verify.js` to reproduce (requires the `solc` npm wrapper for the legacy compiler interface).
