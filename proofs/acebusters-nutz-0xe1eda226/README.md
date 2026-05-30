# Acebusters Nutz (NTZ)

| Field | Value |
|-------|-------|
| Address | `0xe1eda226759825e236831714bcdc0ca0b21fd862` |
| Deployed | 16 September 2017 (block 4,280,239), one month before Byzantium |
| Deployer | `0x1a4faec2f0b3e268494c140f2faafce1791f7719` |
| Tx | `0x9199fd624ec65c500feb1babbd52b3759b6ffd8354d8891e7cf18a6876ceca28` |
| Compiler | `v0.4.16+commit.d7661dd9`, optimizer on (200 runs) |
| Verification | Etherscan verified (contract name `Nutz`) |
| Runtime size | 5,094 bytes |
| Companion | Controller at `0xe7dc501cb9ca414cf9211af214d5065ca3a30768` (also Etherscan-verified) |
| Token | name=`Acebusters Nutz`, symbol=`NTZ`, decimals=12 |
| Active supply (2026-05-30) | ~647,253.4966 NTZ |
| Reserve | 0 ETH on both Nutz and Controller |

## What this contract is

The in-game currency of Acebusters, an on-chain Texas hold'em poker dapp launched in late 2017. The Nutz contract is a thin user-facing proxy: every storage-touching call (`balanceOf`, `totalSupply`, `transfer`, `transferFrom`, `approve`, `allowance`, `floor`, `ceiling`, `powerPool`, `activeSupply`) delegates to the contract's `owner`, which is a separate `Controller` that holds the actual balance map, runs a bonding-curve sell/buy, manages the ETH reserve, and gates an admin pause.

The token implements both **ERC-20 and ERC-223**. The ERC-223 send path inspects the recipient via `EXTCODESIZE` and, if non-zero, calls `tokenFallback(from, value, data)` on the recipient before completing the transfer. The pay-in path is a payable `purchase()` (selector `efef39a1`) and a payable fallback that forwards `msg.value` to `Controller.purchase`, minting NTZ at the current `ceiling()` price. The pay-out paths are `sell(price, amountBabz)` and `powerUp(amountBabz)` for staking into a power pool.

Unit ladder, mirroring `wei / gwei / ether`:

| Decimals | Unit | Honors |
|---|---|---|
| 10^0 | Babz | Charles Babbage |
| 10^3 | Pascalz | Blaise Pascal |
| 10^6 | Helcz | Hermann von Helmholtz |
| 10^9 | Jonyz | John von Neumann (Johnny) |
| 10^12 | Nutz | the token itself |

## Why this contract is interesting

- Combines a **delegating proxy** with a **bonding curve** with a dual **ERC-20 + ERC-223** surface in one coherent design, in September 2017. Predates EIP-1822 (UUPS, 2019) and EIP-1967 (transparent proxy, 2019) by about two years; Acebusters did the controller-owns-proxy split by hand.
- One of the few real-utility on-chain dapp tokens of the 2017 ICO bubble era. Hands ran in state channels and only settlements hit the chain.
- The custom unit ladder shows an unusually playful, mathematician-honoring naming scheme; most 2017 tokens never went beyond `decimals=18` and a single symbol.

## Crack status

**Verified directly on Etherscan.** No reconstruction needed. The verified source is in `Nutz.sol`; the on-chain runtime in `onchain_runtime.hex` (5,094 bytes).

## Files

- `Nutz.sol`, the verified Etherscan source.
- `etherscan_payload.json`, the full Etherscan getsourcecode response (source + ABI + metadata).
- `onchain_runtime.hex`, the on-chain runtime bytecode for reference.

## References

- Companion Controller (verified): https://etherscan.io/address/0xe7dc501cb9ca414cf9211af214d5065ca3a30768#code
- Project on GitHub: https://github.com/acebusters
