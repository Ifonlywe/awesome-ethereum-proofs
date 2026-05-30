# OwnedRegistrar (earliest in-the-wild multicall(bytes[]))

| Field | Value |
|-------|-------|
| Address | `0xa86ba3b6d83139a49b649c05dbb69e0726db69cf` |
| Deployed | October 2018 (block 6,482,390) |
| Deployer | `0x0904dac3` |
| Compiler | v0.4.25+commit.59dbf8f1 |
| Verification | Etherscan verified (contract name `OwnedRegistrar`) |
| Runtime size | 5,054 bytes |
| Purpose | ENS subdomain registrar by the ENS team |

## Why this contract is interesting

Across the 111,821 unique 2018 byzantium-era contract bytecode families in the local lake, exactly **one** contract exposes the selector `0xac9650d8` for `multicall(bytes[])`: this one. That makes it the earliest in-the-wild deployment of `multicall(bytes[])` in the 2018 dataset, and very likely the earliest in Ethereum mainnet history. The MakerDAO/Compound/Multicall2/Uniswap pattern that everyone copies today traces back to a few-line helper sitting at the end of an ENS subdomain registrar.

The implementation, lines 279-283 of the verified source:

```solidity
function multicall(bytes[] calls) public {
    for(uint i = 0; i < calls.length; i++) {
        require(address(this).delegatecall(calls[i]));
    }
}
```

Two notes on the implementation choices that became the template for the pattern:

- `delegatecall(this)` preserves `msg.sender` and contract storage, so the batched calls behave like the user had made them serially.
- No return data is forwarded. Later Multicall2/Uniswap variants added return aggregation; this earliest form is fire-and-forget.

## What the contract does

OwnedRegistrar is an ENS subdomain registrar built for organizations that want to own a single ENS name and hand out subnames to many recipients in batched transactions. The `multicall` helper was the practical primitive that made bulk subdomain provisioning fit in one transaction.

## Files

- `OwnedRegistrar.sol`, the Etherscan-verified source.
- `runtime.hex`, the on-chain runtime bytecode.

## Verification

Already canonically verified on Etherscan (compiler v0.4.25, name `OwnedRegistrar`). This proof folder exists to highlight the multicall significance and to preserve a snapshot of the runtime.
