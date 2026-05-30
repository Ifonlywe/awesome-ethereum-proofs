# CryptoColors (COLOR)

| Field | Value |
|-------|-------|
| Address | `0x3116C449B8980e50DF1047886c6042300Bef9B96` |
| Deployed | February 3, 2018 (block 5,024,415) |
| CEO | `0xfea4bc27a8af27fb317bd1a8538083f648202d1f` |
| Compiler | v0.4.18+commit.9cf6e910 |
| Verification | Etherscan verified + Sourcify exact match |
| Supply | 5 (Red 255,0,0; Blue 0,0,255; Lime 0,255,0; Yellow 255,255,0; Orange 255,127,0) |

## What this contract is

A February 2018 "hot-potato" style collectible game on Ethereum, similar in shape to CryptoCelebrities and CryptoPokemons. The only assets are five primary-color tokens. Calling `purchase(id)` with the asking price atomically transfers the token to the buyer and pays the previous owner; each purchase ratchets the next asking price up.

What sets CryptoColors apart from the rest of the early 2018 hot-potato genre is that the artwork is on chain. Each token has a 24-bit RGB color stored in the contract and exposed through `getColor(uint256)`, so the art is reproducible forever from the contract state, no IPFS or HTTP server required. This is part of the project's broader effort to wrap pre-ERC-721 collectibles into ERC-721 wrappers whose `tokenURI` generates a pure-color SVG live on chain from `getColor`.

The contract uses the pre-standard `NAME()` and `SYMBOL()` (uppercase) getters that return 'CryptoColors' and 'COLOR'. The lower-case ERC-20 `name()` and `symbol()` return empty strings.

## Crack status

Sourcify has an exact byte-for-byte match for this contract, and the Etherscan-verified source is preserved in `CryptoColors.sol` in this folder. No further reconstruction is needed.

## Files

- `CryptoColors.sol`, Etherscan + Sourcify verified source.

## References

- Etherscan: https://etherscan.io/address/0x3116c449b8980e50df1047886c6042300bef9b96#code
- Sourcify: https://sourcify.dev/#/lookup/0x3116c449b8980e50df1047886c6042300bef9b96
