# Belgium (BE)

| Field | Value |
|-------|-------|
| Address | `0x63fd332e120b219f17f1512d530b3780d71ca7c5` |
| Deployed | 2018 (byzantium era) |
| Deployer | `0x95eabb17d286483f6adfdfe0a88b66d894e7d296` |
| Name | Belgium |
| Symbol | BE |
| Decimals | 3 |
| Total supply | 0 (mint-on-buy via fallback) |
| Price | 1 szabo (10^12 wei) per token |
| Runtime size | 10,446 bytes |
| Verification | Unverified on Etherscan |

## What this contract is

A 2018 World Cup fan-token whose on-chain interface mirrors the verified TFWC `EthTeamContract` series exactly: same `price()`, `status()`, `owner()`, `feeOwner()` selectors; payable fallback that mints `msg.value / price` tokens to the sender; `transfer(this, amount)` redeems tokens back into ETH. The contract sits in the same template family as RUSSIA, MOROCCO, FRANCE, CROATIA, BRAZIL deployed by `0x0022a370cdebaff99746b8a1311a8d9734bf3a28`, but Belgium was deployed by a different wallet (`0x95eabb17`) and the runtime is roughly 2x the size of the verified siblings (10,446 bytes vs ~5,400 bytes).

The larger code size suggests the contract bundles extra logic on top of the base TFWC template, possibly an alternative sell path, a paused-cap, or an additional fee mechanic. The deployer wallet has no other contracts matching the TFWC interface, so this is likely a one-off rebrand by a separate author.

Belgium reached the semi-final of the 2018 FIFA World Cup, losing 1 to 0 to France on 10 July 2018.

## Crack status

**NOT cracked.** Identification only at the template-family level. The on-chain interface matches the verified TFWC siblings byte-for-byte at the ABI level (verified by `eth_call` to each selector), but the larger 10kB runtime indicates an extended variant whose source I have not located. EH page records this as `source_reconstructed`.

To attempt a crack: start from the verified `EthTeamContract` source at `0xb389327f8325d9568826b0f3ca63ef613687cfab`, replace the constructor's name and symbol strings with "Belgium" and "BE", and progressively add features (pausing, alternative sell path, fee splitter) until the compiled runtime grows from 5,439 bytes to 10,446 bytes.

## Files

- `runtime.hex`, the on-chain runtime bytecode.

## References

- Verified TFWC sibling: [`TFWC-08-CROATIA`](https://etherscan.io/address/0xb389327f8325d9568826b0f3ca63ef613687cfab#code)
- TFWC series deployer: `0x0022a370cdebaff99746b8a1311a8d9734bf3a28` (different from Belgium's deployer)
