# ETHERLITE (LETH)

| Field | Value |
|-------|-------|
| Address | `0x679ee057b5640987a7dc0dffccc85c669ac9bd02` |
| Deployed | May 2016 (Homestead era) |
| Deployer | `0xe4282c8d102f650882aff3c00dcef89dbdc02d0f` |
| Name | ETHERLITE |
| Symbol | LETH |
| Decimals | 2 |
| Total supply | 1e30 (raw units, so 1e28 at 2 decimals) |
| Runtime size | 2,193 bytes |
| Verification | Unverified on Etherscan |

## What this contract is

A Homestead-era ERC-20-ish token deployed in May 2016, roughly six weeks before The DAO sale opened. Each 0.001 ETH paid into `buy()` mints 99.99 LETH; the contract is part of a small prototyping cluster from deployer `0xe4282c8d`, who also produced the TheDAC series and several "test-N" tokens in a 5-day burst. Follows the ConsenSys HumanStandardToken shape extended with a `unitsOneEthCanBuy` parameter and a fallback-buy path.

The contract is not verified on Etherscan. I have identified the template family but I have not yet produced a candidate source whose compiled runtime matches the deployed bytecode. The runtime has no swarm metadata block, placing the compiler at or before solc 0.4.6.

## Crack status

**NOT cracked.** Identification only at the template-family level. EH page records this as `source_reconstructed` rather than `near_exact_match` or `exact_bytecode_match`.

## Files

- `runtime.hex`, the on-chain runtime bytecode.

## References

- ConsenSys Tokens HumanStandardToken template on GitHub.
- Sibling deploys by `0xe4282c8d`: TheDAC series + test-N tokens (May 4-9, 2016).
