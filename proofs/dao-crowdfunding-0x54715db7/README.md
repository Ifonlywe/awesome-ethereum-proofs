# DAO prototype Crowdfunding (slock.it, December 2015)

- **Address:** `0x54715db7a8a57bc9bab660eb8e7b195774cb564d`
- **Deployer:** `0xb9f40f5b61b5eb9135d268ee0964532f191edab8`
- **Deployment tx:** `0xd9309460d0ff14e3491914bd1bc1c593619083b42134748e910f265695cb5bed`
- **Block:** 767,989 (2015-12-29 22:33:08 UTC)
- **Runtime size:** 6,244 bytes
- **Runtime SHA-256:** `b3f15f4fd3ab702172c3d8cfd4a201b7cca642e75d7762d51278099ce5ac33b1`
- **Balance (May 2026):** 0.884 ETH
- **Crack status: CRACKED.** Compiled source produces byte-for-byte runtime match with the on-chain code.

## Identification

This is the December 2015 prototype DAO/Crowdfunding deployment by Christoph Jentzsch's slock.it team, the same architecture that became The DAO on 30 April 2016. Source comes from `blockchainsllc/DAO` at commit [`b7aeb4e654`](https://github.com/blockchainsllc/DAO/tree/b7aeb4e654), the last commit before this deployment (same calendar day, 3 minutes after the deploy tx).

The deployed contract is `contract DAO is DAOInterface, Token, Crowdfunding(...)` from `DAO.sol` at that commit. Public selectors:

- From `Token.sol`: `transfer(uint,address)`, `transferFrom(address,uint,address)` (pre-EIP-20 arg order with sender LAST), `balanceOf(address)`, `approve(address)`, `unapprove(address)`, `isApprovedFor(address,address)`, `approveOnce(address,uint256)`, `isApprovedOnceFor(address,address)`.
- From `Crowdfunding.sol`: `Crowdfunding(uint256,uint256)` (constructor exposed as runtime selector), `closingTime()`, `minValue()`, `refund()`, `funded()`, `totalAmountReceived()`, `buyToken()`, `buyTokenProxy(address)`.
- From `DAO.sol`: `proposals(uint256)`, `numProposals()`, `vote(uint256,bool)`, `executeProposal(uint256,bytes)`, `checkProposalCode(uint256,address,uint256,bytes)`, `changeProposalDeposit(uint256)`, `confirmNewServiceProvider(uint256,address)`, `newProposal(address,uint256,string,bytes,bool)`, `addAllowedAddress(address)`.

## Crack: exact bytecode match

Compiling `Token.sol`, `Crowdfunding.sol`, and `DAO.sol` in this directory with `soljson-v0.1.7-nightly.2015.11.19+commit.58110b27` (optimizer ON) produces a runtime whose SHA-256 equals the on-chain SHA-256:

```
b3f15f4fd3ab702172c3d8cfd4a201b7cca642e75d7762d51278099ce5ac33b1
```

Run `node verify.js` to reproduce.

### Why this required a nightly, not the v0.1.6 release

Two things had to align for the bytecode to match:

1. **Compiler version.** The compiler linker emits, for each runtime call to the identity precompile (memory copy used during `sha3(...)` arg packing), `PUSH1 15 MUL PUSH1 3 ADD CALL`. That encodes the gas-cost formula `15 * words + 3`. The v0.1.6 release of solc emits `PUSH1 3 MUL PUSH1 15 ADD` (`3 * words + 15`) because it pulls the constants from libethereum's `eth::c_identityGas` and `eth::c_identityWordGas`. Between the v0.1.6 and v0.1.7 releases, libethereum bumped to 1.1.0 and the constants effectively swapped. The first v0.1.7 nightly (commit `58110b27`, 2015-11-19) is the first build that emits the `15*w+3` form.

2. **Source order.** The deployed source declares `transfer(uint,address)` and `transferFrom(address,uint,address)` at the END of the DAO contract body (just before `contract DAO_Creator`), not inside Token. In the GitHub source these two functions live inside `Token`, near the top of the file. Solc emits function bodies in source-declaration order, so moving them to the end relocates ~261 bytes of `transferFrom` body (plus the small "balance < value, return false" helper) to the tail of the runtime, matching the on-chain layout. The bytecode at offset `0x16aa` (transferFrom body in the on-chain code) is identical to `transferFrom` compiled at the end of DAO.

In short: the slock.it dev tree had `transfer` / `transferFrom` defined in the DAO contract rather than the Token contract, and they used a fresh-off-master solc nightly rather than the v0.1.6 release.

### How the crack was found

Working from the v0.1.6 baseline (6,245 bytes, +1 byte off):

- The `+1` byte sat inside `refund()`, in how `balances[msg.sender]` was kept on the stack across the `msg.sender.send(...)` setup.
- Tracking PUSH2 jump destinations through the dispatch table showed that `transferFrom`'s body was at offset `~0x179a` in target but `~0x0bd3` in our compile.
- Moving `transferFrom` to end-of-DAO collapsed the structural diff to 8 bytes; moving `transfer` too dropped it to 11 single-byte differences in 4 clusters.
- The remaining 11 bytes were all `MUL 0x0f ADD 0x03` vs `MUL 0x03 ADD 0x0f` in the identity-precompile gas formula, pointing straight at the libethereum constant swap.
- A sweep across cached solc binaries found `v0.1.7-nightly.2015.11.19` (and `v0.1.7-nightly.2015.11.23`) produce byte-for-byte match with the corrected source order.

## Story

This is the precursor of The DAO. The deployer `0xb9f40f5b...` was a slock.it test wallet. The 0.88 ETH balance has been stuck since the contract's 42-day closing window expired in early February 2016: `minValue` was 500,000 ETH and only fractional ETH was contributed, so the crowdsale failed and the contributions could have been pulled back via `refund()`, but the residual was never claimed.

The same architecture (Token + Crowdfunding + DAO combined into a single deployment via `contract DAO is DAOInterface, Token, Crowdfunding(...)`) was reused for The DAO five months later on 30 April 2016. So this is the direct technical ancestor of the contract that triggered the Ethereum hard fork.

## Files

- `Token.sol`, `Crowdfunding.sol`, `DAO.sol` - cracked source (Token without `transfer`/`transferFrom`; DAO with them appended at the end)
- `target_runtime.txt` - on-chain runtime bytecode (6,244 bytes)
- `verify.js` - reproducer, downloads the compiler if missing and asserts exact SHA-256 match
- `soljson-v0.1.7-nightly.js` - cached compiler binary (`soljson-v0.1.7-nightly.2015.11.19+commit.58110b27`)

## References

- blockchainsllc/DAO: https://github.com/blockchainsllc/DAO
- Specific commit: https://github.com/blockchainsllc/DAO/tree/b7aeb4e654
- The DAO mainnet deployment for comparison: `0xbb9bc244d798123fde783fcc1c72d3bb8c189413`
