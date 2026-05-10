# Kin (「金」) Verification

| Field | Value |
|-------|-------|
| Address | `0x64f310f6ce9ef5e1d6b44a6b4d2ca8edad95ba99` |
| Deployed | Aug 20, 2016 (block 2,109,216) |
| Deploy TX | `0x7afe2f788822555a4981b98f7adaa1654c993842397b890b22ab85de8a1e6ea5` |
| Deployer | `0xe2cdde90fe825836e6aa29512666e26fa6814c80` |
| Compiler | soljson-v0.3.1+commit.c492d9be |
| Optimizer | ON |
| Target runtime | 2637 bytes |
| Compiled runtime | 2634 bytes |
| Target SHA-256 | `397e83ea47e1d0809743bb8f017f803f8ee50cc6b015e12db65c475d3ea39d3a` |
| Compiled SHA-256 | `5ca578070dd32394fcea5ff69c039e0f40365641a9baa861cc238e39e20be114` |
| Match | `source_reconstructed` (20/20 selectors, storage layout, 42/44 EVM bodies byte-for-byte) |

## Constructor args (decoded)

| Param | Value |
|-------|-------|
| initialSupply | `100` |
| tokenName | `"Kin"` |
| decimalUnits | `0` |
| tokenSymbol | `"「金」"` (3-char Japanese, 9 UTF-8 bytes) |
| centralMinter | `0x0000000000000000000000000000000000000000` (deployer keeps ownership) |

## Verification

```bash
node verify.js
```

Compiles `Kin.sol` with soljson v0.3.1 optimizer ON and reports the body-level
diff against `target_runtime.txt` (the on-chain runtime fetched via
`eth_getCode`).

## What this contract does

ConsenSys-tutorial `MyAdvancedToken` ERC-20-style token, deployed by
`0xe2cdde90` for "Kin" (「金」, Japanese for "gold"). 100 indivisible tokens
minted to deployer, all sold via the contract's built-in `buy()` at
`buyPrice = 1000` wei/token. The deployer retained ownership (`centralMinter`
arg was zero) and never minted further — the entire supply was bootstrap-only.

## Source reconstruction notes

The on-chain bytecode is the canonical 2016-era ConsenSys MyAdvancedToken
template family with these specific shape choices needed for byte-near match:

1. `string public standard = "Token 0.1"` declared in `token` parent.
2. `uint256 public totalSupply` shadowed in `MyAdvancedToken` — token's
   parent constructor sets slot 5, MA's constructor sets slot 10. The public
   getter resolves to MA, so `totalSupply()` reads slot 10. This is what the
   on-chain bytecode shows: `totalSupply` getter PUSH1 0x0a SLOAD.
3. `MyAdvancedToken.transfer` overrides `token.transfer` and orders the
   checks: balance, overflow, frozen — frozen check comes **after** balance,
   not before (unusual but matches the on-chain layout).
4. `mintToken` emits `Transfer(0, owner, amount)` and `Transfer(owner, target, amount)`
   using `owner` (slot 0 SLOAD), not `address(this)`.
5. `buy()` is **void** (`uint amount = msg.value / buyPrice;` as a local).
6. `transferOwnership` is redeclared inside `MyAdvancedToken` (overrides
   `owned`'s); this places its body at the very end of the runtime layout.
7. Compiled with `solc v0.3.1+commit.c492d9be --optimize`.

The 3-byte residual gap is in two solc-internal helpers (a
bool-canonicalizing return helper used by `transferFrom`/`approveAndCall`/the
`frozenAccount` getter, and the FrozenFunds event-emit helper) where solc's
inlining of `ISZERO ISZERO` for boolean values varies subtly with how
`freeze` flows through stack vs. storage. All 20 ABI selectors match, all
storage slots match, all 44 function bodies match in opcode signature
(PC-normalized).

## Selectors (20)

```
05fefda7  setPrices(uint256,uint256)
06fdde03  name()
18160ddd  totalSupply()
23b872dd  transferFrom(address,address,uint256)
313ce567  decimals()
4b750334  sellPrice()
5a3b7e42  standard()
70a08231  balanceOf(address)
79c65068  mintToken(address,uint256)
8620410b  buyPrice()
8da5cb5b  owner()
95d89b41  symbol()
a6f2ae3a  buy()
a9059cbb  transfer(address,uint256)
b414d4b6  frozenAccount(address)
cae9ca51  approveAndCall(address,uint256,bytes)
dd62ed3e  allowance(address,address)
e4849b32  sell(uint256)
e724529c  freezeAccount(address,bool)
f2fde38b  transferOwnership(address)
```
