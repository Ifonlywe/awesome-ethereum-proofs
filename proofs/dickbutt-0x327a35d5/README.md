# DickButt Token (DBT) — `0x327a35d52cE91084B15613F57D22Bf068C1f5F9a`

**Crack status: EXACT BYTE-FOR-BYTE MATCH (metadata-stripped).**

## Match

- Compiler: `solc 0.4.15+commit.bbb8e64f` (any 0.4.15 or 0.4.16 commit produces identical runtime)
- Optimizer: on, runs=200
- On-chain runtime: 3,949 bytes
- Compiled runtime: 3,949 bytes
- Identical SHA-256 after stripping the trailing 43-byte `bzzr0` metadata:
  - `c5cfa19cdb6e2d64e85a72b762b9ea8000b65f706ea238ee7aef9b11fa8dc59b`
- Only the trailing 32-byte swarm hash inside the metadata differs, as expected for any source whose absolute file path is not the original deployer's.

## What it is

An ERC-20 token deployed on 2017-11-13 by `0x30F7514ac1cC09648aa9Fb5bdF3452feB8B6d266`. The contract is an OpenZeppelin `MintableToken + BurnableToken` extended with a fallback-purchase pattern: sending ETH calls `buyTo(msg.sender)`, which forwards the ETH to the owner wallet and transfers `(value * 1 ether) / price` DBT from the owner's pre-stocked balance to the buyer. The initial price is `10 szabo` (10^13 wei) and `totalSupply = 1,000,000 * 10^18`.

The owner can call `setPrice` and `mint`, so the pre-stocked supply is not strictly fixed. As of 2026-05, the owner wallet holds only ~1 gwei of ETH (presumed lost key), so practical mint and ETH-withdrawal are dead.

## How to reproduce the crack

```bash
# solc 0.4.15, 0.4.16, 0.4.17, or 0.4.18 all produce identical functional bytecode
solc --bin-runtime --optimize --optimize-runs 200 DickButtToken.sol
# strip a165627a7a72305820...0029 trailing metadata from both sides
python3 -c "
import hashlib
marker = bytes.fromhex('a165627a7a72305820')
c = bytes.fromhex(open('compiled_runtime.hex').read().strip())
o = bytes.fromhex(open('onchain_runtime.hex').read().strip())
cs = c[:c.find(marker)]; os = o[:o.find(marker)]
assert cs == os, 'mismatch'
print('stripped SHA-256:', hashlib.sha256(cs).hexdigest())
# c5cfa19cdb6e2d64e85a72b762b9ea8000b65f706ea238ee7aef9b11fa8dc59b
"
```

## Files

- `DickButtToken.sol` — full source (SafeMath, Ownable, ERC20Basic, ERC20, BasicToken, StandardToken, MintableToken, BurnableToken, DickButtToken)
- `onchain_runtime.hex` — runtime bytecode fetched via `eth_getCode`
- `compiled_runtime.hex` — output of `solc 0.4.15 --bin-runtime --optimize --optimize-runs 200`
