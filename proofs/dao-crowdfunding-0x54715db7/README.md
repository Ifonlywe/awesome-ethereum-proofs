# DAO prototype Crowdfunding (slock.it, December 2015)

- **Address:** `0x54715db7a8a57bc9bab660eb8e7b195774cb564d`
- **Deployer:** `0xb9f40f5b61b5eb9135d268ee0964532f191edab8`
- **Deployment tx:** `0xd9309460d0ff14e3491914bd1bc1c593619083b42134748e910f265695cb5bed`
- **Block:** 767,989 (2015-12-29 22:33:08 UTC)
- **Runtime size:** 6,244 bytes
- **Balance (May 2026):** 0.884 ETH
- **Crack status: NOT cracked.** Closest reproducer is 6,245 bytes (1 byte longer), see `CRACK_ATTEMPT.md`.

## Identification

This is the December 2015 prototype DAO/Crowdfunding deployment by Christoph Jentzsch's slock.it team, the same architecture that became The DAO on 30 April 2016. Source comes from `blockchainsllc/DAO` at commit [`b7aeb4e654`](https://github.com/blockchainsllc/DAO/tree/b7aeb4e654), the last commit before this deployment (same calendar day, 3 minutes after the deploy tx). Note: the GitHub commit is timestamped 3 minutes AFTER the on-chain deployment, suggesting the deployed source had local edits never pushed.

The deployed contract is `contract DAO is DAOInterface, Token, Crowdfunding(...)` from `DAO.sol` at that commit. Selector decode of the deployed bytecode resolves cleanly against the union of `Token.sol`, `Crowdfunding.sol`, and `DAO.sol`:

- From `Token.sol`: `transfer(uint,address)`, `transferFrom(address,uint,address)` (note OLD pre-EIP-20 arg order with sender LAST), `balanceOf(address)`, `approve(address)`, `unapprove(address)`, `isApprovedFor(address,address)`, `approveOnce(address,uint256)`, `isApprovedOnceFor(address,address)`.
- From `Crowdfunding.sol`: `Crowdfunding(uint256,uint256)` (constructor exposed as runtime selector), `closingTime()`, `minValue()`, `refund()`, `funded()`, `totalAmountReceived()`, `buyToken()`, `buyTokenProxy(address)`, `addAllowedAddress(address)`.
- From `DAO.sol`: `proposals(uint256)`, `numProposals()`, `vote(uint256,bool)`, `executeProposal(uint256,bytes)`, `checkProposalCode(uint256,address,uint256,bytes)`, `changeProposalDeposit(uint256)`.

## Crack attempt result (NOT cracked)

Compiled with `soljson-v0.1.6+commit.d41f8b7c` (optimizer ON), the source produces a 6,245-byte runtime vs the on-chain 6,244 bytes. The first 86 bytes of the dispatch table match byte-for-byte; the next ~6,160 bytes diverge in ways consistent with one source-level edit.

Diff analysis using difflib.SequenceMatcher:
- mine 6,245 bytes, target 6,244 bytes (net +1 byte)
- First divergence at byte offset 172
- 31 diff regions total, most are 1-2 byte jump-destination shifts cascading from one root cause
- 261-byte function appears at offset 3,028 in mine but at offset 5,795 in target (function moved to near end)
- 2-byte `5190` (MLOAD SWAP1) extra at offset 1,591 in mine, 1-byte `51` (MLOAD) extra at 1,595 in target (net +1)
- 4 byte-pair swaps (`0f`/`03`) in inline assembly for sha3 padding

Tested earlier commits 95d85c6f48, 90a14073a3, 52b0a0f88a, b2cad2182f. All produce only ~18-byte prefix match (the contract structure was different prior to b7aeb4e654).

Tested solc versions: v0.1.5 fails to compile (no `.push()` on `address[]`). v0.1.6 and v0.1.7 produce 6,245 bytes. v0.2.x produces 6,247. v0.3.0-0.3.2 produces 6,250. v0.3.3+ produces 6,291.

The compiler version (v0.1.6) is consistent with the deployment date (29 December 2015, v0.1.6 was current). The 1-byte deficit and the 261-byte function reorder strongly suggest the deployed source was a local edit that never landed on GitHub.

What would close it: a snapshot of the deployment-time local source, OR brute-forcing function permutations (intractable for 24 functions).

## Story

This is the precursor of The DAO. The deployer 0xb9f40f5b... was a slock.it test wallet. The 0.88 ETH balance has been stuck since the contract's 42-day closing window expired in early February 2016: minValue was 500,000 ETH and only fractional ETH was contributed, so the crowdsale failed and the contributions could have been pulled back via refund(), but the residual was never claimed.

The same architecture (Token + Crowdfunding + DAO combined into a single deployment via `contract DAO is DAOInterface, Token, Crowdfunding(...)`) was reused for The DAO five months later on 30 April 2016. So this is the direct technical ancestor of the contract that triggered the Ethereum hard fork.

## Files

- `Token.sol`, `Crowdfunding.sol`, `DAO.sol` - source from blockchainsllc/DAO@b7aeb4e654
- `target_runtime.txt` - on-chain runtime bytecode (6,244 bytes)
- `verify.js` - best reproducer (produces 6,245 bytes, 1 byte off)
- `CRACK_ATTEMPT.md` - detailed diff analysis

## References

- blockchainsllc/DAO: https://github.com/blockchainsllc/DAO
- Specific commit: https://github.com/blockchainsllc/DAO/tree/b7aeb4e654
- The DAO mainnet deployment for comparison: `0xbb9bc244d798123fde783fcc1c72d3bb8c189413`
