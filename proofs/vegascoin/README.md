# VegasCoin (VEGAS) Verification

| Field | Value |
|-------|-------|
| Address | `0x616f026ec265097290e34a76405949f9fa7050b3` |
| Deployed | Jan 26, 2017 (block 3,066,437) |
| Deploy TX | `0xd53ae254e864ae00d508f0badd2fef6ff71b78bb6b96c887a064fa309fa1f528` |
| Deployer | `0xc081e03b090251e21d364a0ff61c91d918ae4b01` |
| Compiler | soljson-v0.4.6+commit.2dabbdf0 |
| Optimizer | ON |
| Target runtime | 3344 bytes |
| Compiled runtime | 3341 bytes |
| Target SHA-256 | `4b485137dec378fc01c8abd2dc0023c9f1c5b9fb29a2a3f48257b41080d5604e` |
| Compiled SHA-256 | `c0226f2672d4decbe8664bcf1c04e7fc70514bfeea53e87698272d25ae3e5473` |
| Match | `source_reconstructed` (21/21 selectors, storage layout, 107/111 EVM bodies byte-for-byte) |

## Constructor args (decoded)

| Param | Value |
|-------|-------|
| initialSupply | `777,777,777` |
| tokenName | `"VegasCoin"` |
| decimalUnits | `0` |
| tokenSymbol | `"VEGAS"` |
| centralMinter | `0x0000000000000000000000000000000000000000` (deployer keeps ownership) |

The deployer also patched the inherited `string public standard` to
`"VegasCoin 2.1"` (instead of the canonical default `"Token 0.1"`), readable
on-chain as `standard()`.

## Verification

```bash
node verify.js
```

Compiles `VegasCoin.sol` with soljson v0.4.6 optimizer ON and reports the
body-level diff against `target_runtime.txt`.

## What this contract does

ConsenSys-tutorial `MyAdvancedToken` ERC-20-style token, deployed by
`0xc081e03b` for "VegasCoin" (VEGAS). 777,777,777 indivisible tokens minted
to deployer, all sold via `buy()` at `buyPrice = 1` wei/token. There were
multiple VegasCoin deployments by the same operator on Jan 25–26, 2017
(see `targets/buyable-tokens-scan-results.csv` in the cracker repo); this is
the one with `buyPrice = 1` and full supply pre-sold to the contract for
public buy.

## Source reconstruction notes

The contract is the canonical mid-2016 ConsenSys MyAdvancedToken template,
recompiled here with solc 0.4.6 to match the on-chain bytecode's
`payable`-aware function entries:

1. `string public standard = "VegasCoin 2.1"` (deployer customized the
   inherited default `"Token 0.1"`).
2. `uint256 public totalSupply` shadowed in `MyAdvancedToken` — token's
   parent constructor sets slot 5, MA's constructor sets slot 10; the
   `totalSupply()` getter reads slot 10.
3. `function buy() payable` — solc 0.4.x emits an explicit `CALLVALUE`
   non-payable check at every function entry, so `buy()` (the only ETH-
   receiving function) needs the `payable` modifier.
4. `mintToken` emits `Transfer(0, this, ...)` and `Transfer(this, target, ...)`
   using `address(this)` (the on-chain bytecode uses the `ADDRESS` opcode at
   both LOG3 sites).
5. `sell` uses an explicit `if (msg.sender.send(...)) { ... } else { throw; }`
   structure rather than the inverted `if (!sent) throw;` form — this changes
   how solc 0.4.6 lays out the success-path event-emit helper.
6. `transferOwnership` redeclared inside `MyAdvancedToken` (places its body
   at the very end of the runtime).
7. Compiled with `solc v0.4.6+commit.2dabbdf0 --optimize`.

The 3-byte residual gap is in three small solc-internal helpers (the
`approve` named-return wrap-up, a 4-byte difference in the `Transfer` event
helper layout for `sell`, and a 1-byte standalone `JUMPDEST`). All 21 ABI
selectors match, all storage slots match, 107 of 111 function bodies match
byte-for-byte in normalized form.

## Selectors (21)

```
05fefda7  setPrices(uint256,uint256)
06fdde03  name()
095ea7b3  approve(address,uint256)
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
