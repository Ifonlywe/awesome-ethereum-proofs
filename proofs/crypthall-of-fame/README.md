# CryptHall Of Fame (HeroToken) — Source Recovery

| Field | Value |
|-------|-------|
| Canonical address | [`0x04cef5553cfea50288d325ddfa305f1b133bd45e`](https://etherscan.io/address/0x04cef5553cfea50288d325ddfa305f1b133bd45e) |
| Sibling address | [`0xb041de495505262e113d090edc9633389e1a3596`](https://etherscan.io/address/0xb041de495505262e113d090edc9633389e1a3596) |
| Deployed | Feb 08, 2018 (block ~5,055,300) |
| Deployer | `0xc1E83b6004f94729fF9CFa5db5B4C744150b2619` ([colmea.eth](https://etherscan.io/address/0xc1E83b6004f94729fF9CFa5db5B4C744150b2619)) |
| Compiler | `soljson-v0.4.18+commit.9cf6e910` |
| Optimizer | OFF (runs 200) |
| Runtime | 10,022 bytes |
| Creation | 10,193 bytes |
| Runtime SHA-256 | `dc2075f83824b82c7c49f3dc1a92e5b08dfec7b185b189a16697d88f70e9ede6` |
| Creation SHA-256 | `af46d2869679d55e62acd9bb6cc8d7192b7bc7d156e961e11f53c7589af74640` |
| Match | Exact bytecode match (runtime and creation, modulo bzzr metadata hash) |
| Proved by | [@cartoonitunes](https://ethereumhistory.com/historian/12) |

## What this contract is

CryptHall Of Fame is a personal NFT scrapbook built by Belgian developer **colmea.eth** (ENS), deployed in February 2018 at the height of the post-CryptoKitties collectible boom. Twelve heroes were minted — five named, seven unnamed placeholders — and sold to a small circle of friends and family rather than the open market.

Named heroes include members of the **De Sprimont** family, the deployer's friend **Hadrien**, the family dog **Noukie**, a **Kylo Ren** (Star Wars), and a **Belle panthère**.

The contract is a fork of the verified [CelebrityToken](https://etherscan.io/address/0xbb5ed1edeb5149af3ab43ea9c7a6963b3c1374f7#code) template (CryptoCelebrities, by Axiom Zen) with three customizations on top of the base ERC-721-draft:

1. **Four-string `Hero` struct** instead of the original single-name struct:
   ```solidity
   struct Hero { string slug; string name; string imageFilename; string heroName; }
   ```
2. **Owner-renameable display** via `updateHero(uint256, string, string)` — the current owner can rewrite `imageFilename` and `heroName` to personalize their token.
3. **Simplified single-step pricing** — `price * 150 / 94` on every purchase (a fixed 60% markup with 6% to the seller as fee retention), no multi-tier escalation. Starting price `0.003 ether`.

Admin functions: `createNewHero(string)` (COO-only, contract-owned), `createSpecialHero(address, string, uint256)` (COO-only, pre-assigned), `resetImage(uint256)` (CLevel), `setCEO`, `setCOO`, `payout`. Standard ERC-721-draft: `approve`, `transferFrom`, `takeOwnership`, `transfer`, `balanceOf`, `ownerOf`, `tokensOfOwner`, `priceOf`.

## Verification

```bash
node compile.js v0.4.18+commit.9cf6e910 HeroToken.sol HeroToken 0
diff <(xxd compiled_runtime.hex) <(xxd target_runtime.txt)
```

Output matches the on-chain runtime byte-for-byte except for the bzzr metadata hash at the tail (always varies with comments/whitespace, irrelevant to execution).

## Storage layout (verified against constructor SSTOREs and 36 runtime SHA3-mapping accesses)

| Slot | Field | Type |
|------|-------|------|
| 0 | `startingPrice` | `uint256 private` (= `0.003 ether`) |
| 1 | `heroIndexToOwner` | `mapping(uint256 => address) public` |
| 2 | `ownershipTokenCount` | `mapping(address => uint256) private` |
| 3 | `heroIndexToApproved` | `mapping(uint256 => address) public` |
| 4 | `heroIndexToPrice` | `mapping(uint256 => uint256) private` |
| 5 | `ceoAddress` | `address public` |
| 6 | `cooAddress` | `address public` |
| 7 | `heroCreatedCount` | `uint256 public` |
| 8 | `heroes` | `Hero[] private` (4 slots per element) |

## Selectors (28, all matched)

| Selector | Function |
|----------|----------|
| `0x06ba3a4c` | `createSpecialHero(address,string,uint256)` |
| `0x06fdde03` | `name()` |
| `0x095ea7b3` | `approve(address,uint256)` |
| `0x0a0f8168` | `ceoAddress()` |
| `0x0b7e9c44` | `payout(address)` |
| `0x1051db34` | `implementsERC721()` |
| `0x18160ddd` | `totalSupply()` |
| `0x21d80111` | `getHero(uint256)` |
| `0x23b872dd` | `transferFrom(address,address,uint256)` |
| `0x27d7874c` | `setCEO(address)` |
| `0x2ba73c15` | `setCOO(address)` |
| `0x6352211e` | `ownerOf(uint256)` |
| `0x70a08231` | `balanceOf(address)` |
| `0x8462151c` | `tokensOfOwner(address)` |
| `0x91f344ea` | `heroCreatedCount()` |
| `0x95d89b41` | `symbol()` |
| `0x9c243964` | `resetImage(uint256)` |
| `0xa3f4df7e` | `NAME()` |
| `0xa5eddb23` | `updateHero(uint256,string,string)` |
| `0xa9059cbb` | `transfer(address,uint256)` |
| `0xaa54beac` | `heroIndexToOwner(uint256)` |
| `0xb047fb50` | `cooAddress()` |
| `0xb2e6ceeb` | `takeOwnership(uint256)` |
| `0xb9186d7d` | `priceOf(uint256)` |
| `0xde3e305f` | `heroIndexToApproved(uint256)` |
| `0xefef39a1` | `purchase(uint256)` |
| `0xf53a0fab` | `createNewHero(string)` |
| `0xf76f8d78` | `SYMBOL()` |

## Source reconstruction notes

Three findings drove the byte-exact match:

1. **No `firstStepLimit`/`secondStepLimit` state vars.** Constructor SSTOREs only `startingPrice` (slot 0) and the two C-level addresses; the runtime has no multi-step price check in `purchase()`. The single-step formula `price * 150 / 94` was found at PCs `0x1adf-0x1ae6` (mul by 0x96 / div by 0x5e).

2. **`updateHero` uses a `Hero storage` local.** Target computes `keccak256(tokenId, 8) + 4*tokenId` once and reuses it for both struct field writes (slot+2 imageFilename, slot+3 heroName). Reproducing this required:
   ```solidity
   Hero storage hero = heroes[_tokenId];
   hero.imageFilename = _imageFilename;
   hero.heroName = _heroName;
   ```
   The hoisted-local pattern produces target's `PUSH1 0x00` placeholder at function entry and the `SWAP1 POP` slot-cache assignment after the SHA3.

3. **`resetImage` also uses a `Hero storage` local** (same hoisted-pattern shape) and skips the explicit `require(_tokenId < totalSupply())` — the array-element access `heroes[_tokenId]` reverts on out-of-bounds inline via the `SLOAD DUP2 LT INVALID` pattern at the struct-slot computation, so the redundant explicit check was omitted from source.

## Related links

- Etherscan verified source: [0xb041de4955...3596 #code](https://etherscan.io/address/0xb041de495505262e113d090edc9633389e1a3596#code)
- Sourcify match: [repo.sourcify.dev](https://repo.sourcify.dev/contracts/full_match/1/0xb041De495505262E113D090EDc9633389e1a3596/)
- Template lineage: [CelebrityToken (CryptoCelebrities)](https://etherscan.io/address/0xbb5ed1edeb5149af3ab43ea9c7a6963b3c1374f7#code)
- Deployer: [colmea.eth](https://etherscan.io/address/0xc1E83b6004f94729fF9CFa5db5B4C744150b2619)
