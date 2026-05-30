# Early on-chain exchange ("GEMS"), 11 May 2016

- **Address:** `0xfdc77b9cb732eb8c896b152e28294521f5f62e67`
- **Deployer:** `0xdf7e1f46f3a53552c168f28ad95ef5eab6283178`
- **Deployment tx:** `0xcd6c037a7cb9798ae6b31048ac197fdcce49b27c3f6550c883d02acd273040db`
- **Block:** 1,499,223 (2016-05-11 19:57:42 UTC)
- **Runtime size:** 14,981 bytes
- **Balance (May 2026):** 14.15 ETH
- **Verification status:** source_reconstructed (architecture identified from selector decode + transaction-pattern analysis; no source repo found)

## Architecture (from selector decode)

The contract is the main module of a six-contract exchange system. The same deployer wallet deployed seven contracts in two batches the same day:

| Block | Address | Gas used | Likely role |
|-------|---------|----------|-------------|
| 1499016 | 0xf361ff1b... | 356,569 | Library (first deploy) |
| 1499026 | 0x23f300fe... | 2,326,936 | Module A (first deploy) |
| 1499028 | 0x312ff954... | 2,712,195 | Module B (first deploy) |
| 1499039 | 0xb4e202aa... | 1,590,415 | Module C (first deploy) |
| 1499043 | 0xc323e7eb... | 1,983,300 | Module D (first deploy) |
| 1499045 | 0xee1e0800... | 1,235,648 | Module E (first deploy) |
| **1499177** | **0x8f57162e...** | 356,569 | **multiowned library (redeploy, referenced by exchange runtime)** |
| 1499180 | 0xa243edcb... | 2,326,936 | Module A (redeploy) |
| 1499196 | 0xe0a1c99b... | 2,712,195 | Module B (redeploy) |
| 1499200 | 0x0b910cdb... | 1,590,415 | Module C (redeploy) |
| 1499210 | 0xafd43bfa... | 1,983,300 | Module D (redeploy) |
| 1499214 | 0x9e80340e... | 1,235,648 | Module E (redeploy) |
| **1499223** | **0xfdc77b9c...** | **4,476,922** | **Exchange main contract (this one)** |

The redeploy at 1499177-1499214 is byte-identical to the first batch (same gas means same code). The exchange at 1499223 makes a `DELEGATECALL` into the multiowned library at `0x8f57162e...` (the library address is hardcoded as a 20-byte literal in this contract's runtime), so the multisig/owner-management logic lives there and the exchange only contains the trading logic.

## Selector groups (63 total)

Resolved against openchain.xyz; many remain unresolved.

**Multiowned (delegatecall into 0x8f57162e):**
- `addOwner(address)` `removeOwner(address)` `isOwner(address)` `changeOwner(address,address)` `changeRequirement(uint256)` `m_required()` `hasConfirmed(bytes32,address)` `revoke(bytes32)`

**Locking:**
- `locked()` `lock()` `unlock()` `ERROR_LOCKED()` `ERROR_INSUFFICIENT_BALANCE()`

**User registry:**
- `addUser(uint256,address)` `userId()` `getUser(uint256)`

**Bank accounts:**
- `bank()` `ethBank()`

**Exchange operations:**
- `exchange()` `rate()` `setExchangeRates(uint256,uint256)` `closeSell(uint256)` `exchangeWithdraw()`

**Off-chain oracle:**
- `setApiAddress(address)` `apiAddress()`

**Unresolved (~35 selectors):** application-specific methods. Examples include `0x06c3a2fc`, `0x0a8736d5`, `0x0d4a4723`, `0x1e4c8683`, `0x21096830`, etc.

## Operational history

After deployment the deployer:

1. Block 1499237 - `setApiAddress(...)`
2. Block 1499259-75 - `addOwner` called four times (built a 4-of-N multisig)
3. Block 1499278 - `changeRequirement(...)`
4. Block 1499394 - the API client wallet `0xcaa216e03ee4932941ef0729f250` started bulk-calling `addUser(uint, address)` (seven calls in a single block) to seed the user database

This pattern is consistent with a fully off-chain settlement model: customers' identity and balances are tracked off-chain by the API service at the address set via `setApiAddress`; the on-chain contract is the trust anchor that holds ETH and confirms trades signed by the off-chain oracle.

## Why this is hard to crack byte-for-byte

- 14,981 bytes of runtime is large enough that even a perfect Solidity source would diverge at the 1-byte level from many optimizer settings.
- The hardcoded multiowned library address (`0x8f57162ef4204e383cdd7ca55c11ab374e23634d`) suggests the deployer treated the library as a fixed external; the exchange source would have to reference that exact constant.
- No GitHub source for the exchange or its UI has been found by name or selector search.
- The 35 unresolved selectors imply application-specific method names ("GEMS"-flavoured) that exist nowhere in the public selector databases.

A full crack requires either contacting the deployer or reverse-engineering from the public storage layout + decompilation.

## References

- Deployer: https://etherscan.io/address/0xdf7e1f46f3a53552c168f28ad95ef5eab6283178
- Multiowned library: https://etherscan.io/address/0x8f57162ef4204e383cdd7ca55c11ab374e23634d
- This contract: https://etherscan.io/address/0xfdc77b9cb732eb8c896b152e28294521f5f62e67
