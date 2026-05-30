# DAO prototype Crowdfunding (slock.it, December 2015)

- **Address:** `0x54715db7a8a57bc9bab660eb8e7b195774cb564d`
- **Deployer:** `0xb9f40f5b61b5eb9135d268ee0964532f191edab8`
- **Deployment tx:** `0xd9309460d0ff14e3491914bd1bc1c593619083b42134748e910f265695cb5bed`
- **Block:** 767,989 (2015-12-29 22:33:08 UTC)
- **Runtime size:** 6,244 bytes
- **Balance (May 2026):** 0.884 ETH
- **Verification status:** near_exact_match (source from repo, byte-identical first 86 bytes; remainder diverges by ~6 bytes)

## Identification

This is the December 2015 prototype DAO/Crowdfunding deployment by Christoph Jentzsch's slock.it team, the same group that later launched The DAO on 30 April 2016. Source comes from `blockchainsllc/DAO` at commit [`b7aeb4e654`](https://github.com/blockchainsllc/DAO/tree/b7aeb4e654), the last commit before this deployment (same calendar day, 5 hours earlier).

The deployed contract is `contract DAO is DAOInterface, Token, Crowdfunding(...)` from `DAO.sol` at that commit. Selector decode of the deployed bytecode resolves cleanly against the union of `Token.sol`, `Crowdfunding.sol`, and `DAO.sol`:

- From `Token.sol`: `transfer(uint,address)`, `transferFrom(address,uint,address)` (note OLD pre-EIP-20 arg order with sender LAST), `balanceOf(address)`, `approve(address)`, `unapprove(address)`, `isApprovedFor(address,address)`, `approveOnce(address,uint256)`, `isApprovedOnceFor(address,address)`.
- From `Crowdfunding.sol`: `Crowdfunding(uint256,uint256)` (constructor exposed as runtime selector), `closingTime()`, `minValue()`, `refund()`, `funded()`, `totalAmountReceived()`, `buyToken()`, `buyTokenProxy(address)`, `addAllowedAddress(address)`.
- From `DAO.sol`: `proposals(uint256)`, `numProposals()`, `vote(uint256,bool)`, `executeProposal(uint256,bytes)`, `checkProposalCode(uint256,address,uint256,bytes)`, `changeProposalDeposit(uint256)`.

## Reproducer status

Compiled with Solidity v0.3.2+commit.81ae2a78 (optimizer ON), the source produces a 6,250-byte runtime versus the on-chain 6,244 bytes. The first 86 bytes (the function-dispatch table for the first 5 selectors) match byte-for-byte. The remaining bytes diverge.

Likely causes of the small mismatch:
- The deployment is from a slightly different commit (the repo's git history continued evolving in the weeks around deployment; `b7aeb4e654` is the closest *visible* commit but the team may have had unpublished local edits).
- Solidity v0.3.2 was released June 2016, six months *after* deployment, so the deployer used an earlier version (v0.1.7 / v0.2.x) whose code-gen differs slightly. Earlier soljson versions fail to compile the file as-is due to syntax incompatibilities with the DAO source.

A byte-for-byte crack is achievable but requires manually backporting the source to v0.1.7 syntax (modifier syntax, `import` semantics).

## Story

This is the precursor of The DAO. The deployer 0xb9f40f5b61b5eb9135d268ee0964532f191edab8 was a slock.it test wallet. The 0.88 ETH balance has been stuck since the contract's `closingTime` passed in early 2016 (42-day default per `Crowdfunding(500000 ether, now + 42 days)` constructor in DAO.sol line 106). Since the `minValue` was 500,000 ETH and only fractional ETH was contributed, refunds were available via `refund()`, but the few wei that remained were never claimed.

The same architecture (Token + Crowdfunding + DAO combined into a single deployment via `contract DAO is DAOInterface, Token, Crowdfunding(...)`) was reused for The DAO five months later on 30 April 2016. So this is the direct technical ancestor of the contract that triggered the Ethereum hard fork.

## Files

- `Token.sol`, `Crowdfunding.sol`, `DAO.sol` - source from blockchainsllc/DAO@b7aeb4e654
- `target_runtime.txt` - on-chain runtime bytecode (6,244 bytes)

## References

- blockchainsllc/DAO: https://github.com/blockchainsllc/DAO
- Specific commit: https://github.com/blockchainsllc/DAO/tree/b7aeb4e654
- The DAO mainnet deployment for comparison: `0xbb9bc244d798123fde783fcc1c72d3bb8c189413`
