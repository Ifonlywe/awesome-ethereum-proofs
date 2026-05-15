# AkivaCoin Verification

| Field | Value |
|-------|-------|
| Address | `0xcffafced915d6cc3e9b05ef38b52f0bccd897e91` |
| Deployed | Aug 2, 2017 (block 4,106,618) |
| Compiler | soljson v0.4.12+commit.194ff033 |
| Optimizer | ON, runs=200 |
| Runtime | 2,923 bytes |
| Token | AkivaCoin (✌️) |
| Verification | `source_reconstructed` — bytecode matches byte-for-byte excluding metadata hash |

## Verification

Compile with solc v0.4.12 (optimizer enabled, runs=200):

```bash
solcjs --optimize --bin-runtime AkivaCoin.sol
```

The compiled runtime bytecode matches the on-chain deployed runtime exactly through byte 2879 (all 2,880 code bytes). The trailing 43 bytes (the CBOR-encoded swarm metadata hash at the end) differ because the metadata hash is derived from source formatting and cannot be reproduced without the original whitespace.

## Notes

- Standard ConsenSys MyAdvancedToken pattern, simplified — no transferFrom, no mintToken, no freezeAccount
- Owner sets sellPrice and buyPrice via setPrices
- buy() mints tokens at msg.value/buyPrice
- sell() burns tokens and pays `amount * sellPrice` wei back via msg.sender.transfer()
- Final dead `if (false) {}` in sell() emits a stray JUMPDEST that the optimizer doesn't eliminate — required to match the on-chain layout

## Storage layout

| Slot | Type | Name |
|---|---|---|
| 0 | address | owner |
| 1 | string | standard ("Token 0.1") |
| 2 | string | name |
| 3 | string | symbol |
| 4 | uint8 | decimals |
| 5 | uint256 | totalSupply |
| 6 | mapping | balanceOf |
| 7 | mapping | allowance |
| 8 | uint256 | sellPrice |
| 9 | uint256 | buyPrice |
