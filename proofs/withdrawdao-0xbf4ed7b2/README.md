# WithdrawDAO

| Field | Value |
|-------|-------|
| Address | `0xbf4ed7b27f1d666546e30d74d50d173d20bca754` |
| Deployed | July 2016 (right before the hard fork) |
| Author | Ethereum Foundation (post-DAO-hack salvage contract) |
| Compiler | v0.3.5-2016-07-01-48238c9 |
| Verification | Etherscan verified (contract name `WithdrawDAO`) |
| Current balance | **81,715.77 ETH** (verified 2026-05-30) |

## What this contract is

The post-hard-fork redemption contract for the original DAO. After the July 20, 2016 hard fork that reverted the DAO drain, all DAO tokens became redeemable for ether at a fixed ratio of 1 DAO = 1/100 ETH. Holders called `withdraw()`, which atomically transferred their DAO balance to this contract and sent them the equivalent ETH.

Almost ten years later, **the contract still holds 81,715.77 ETH**. At current prices that is roughly 327 million dollars. This is the single largest dead-contract treasury on Ethereum: tokens were widely distributed in the original DAO sale (around 11,000 holders) and a significant fraction of them never showed up to claim. Some lost keys, some never noticed the fork, some had already written off the DAO loss and moved on.

A `trusteeWithdraw()` function lets the trustee at `0xda4a4626d3e16e094de3225a751aab7128e96526` sweep any surplus balance after all DAO tokens have been redeemed (`balance + mainDAO.balanceOf(this) - mainDAO.totalSupply()`). Because not every token has been redeemed, the trustee path has nothing to sweep yet.

## The contract

The runtime is 1,122 bytes and contains two callable functions:

| Selector | Function | Effect |
|----------|----------|--------|
| `0x3ccfd60b` | `withdraw()` | Pulls caller's DAO tokens, sends ETH at 1:100 ratio |
| `0xc06c061b` | `trusteeWithdraw()` | Sweeps surplus to the trustee address |

The DAO token contract is hardcoded at `0xbb9bc244d798123fde783fcc1c72d3bb8c189413`.

## Why this matters

This is the on-chain artifact of the most consequential governance event in Ethereum history: the chain that did not split (now ETH) descends from this contract being honoured. The 81,715 ETH parked here is a permanent reminder of how many people the fork left behind, on the way to making the rest of us whole.

## Files

- `WithdrawDAO.sol`, the Etherscan-verified source.
- `runtime.hex`, the on-chain runtime bytecode.
