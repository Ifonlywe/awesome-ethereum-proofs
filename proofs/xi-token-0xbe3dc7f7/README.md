# Xi (Ξ)

| Field | Value |
|-------|-------|
| Address | `0xbe3dc7f74ce3ebdd44f7bfedde87aec8d7cab9df` |
| Deployed | May 2016 (DAO era) |
| Name | Xi |
| Symbol | Ξ (Greek capital letter xi) |
| Decimals | 0 |
| Total cap | 15,000 |
| Runtime size | 2,097 bytes |
| Verification | Unverified on Etherscan |

## What this contract is

A small May 2016 token deployed just before The DAO sale opened. The symbol is the Greek capital letter Ξ (xi), a wink at the price tickers that label Ethereum prices with "Ξ". The token follows the shape of the ConsenSys HumanStandardToken template (standard ERC-20 selectors plus a basic `buy()` path that mints into the caller's balance), capped at 15,000 with zero decimals and priced at 1 token per 0.001 ETH.

The contract is not verified on Etherscan. I have identified the template family (ConsenSys HumanStandardToken) but I have not yet produced a candidate source whose compiled runtime matches the deployed bytecode. The runtime has no swarm metadata block, which places the compiler at or before solc 0.4.6, and uses the early `CALLDATASIZE-ISZERO` dispatch pattern at the top of the runtime.

## Crack status

**NOT cracked.** Identification only at the template-family level. EH page records this as `source_reconstructed` rather than `near_exact_match` or `exact_bytecode_match`.

## Files

- `runtime.hex`, the on-chain runtime bytecode.

## References

- ConsenSys Tokens template family on GitHub.
