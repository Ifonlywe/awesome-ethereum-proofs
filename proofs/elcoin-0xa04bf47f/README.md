# Elcoin (ELC) — Source Reconstruction

| Field | Value |
|-------|-------|
| Address | `0xa04bf47f0e9d1745d254b9b89f304c7d7ad121aa` |
| Deployed | Jan 27, 2016 (block 912,760) |
| Deployer | `0x48175Da4c20313bcb6B62d74937d3fF985885701` |
| Runtime | 10,824 bytes |
| Runtime SHA-256 | `8b0fadbad271c31dc17607a7bd641a54793dd4c7545c4a5dafd7e22c19df0d87` |
| Compiler | solc 0.1.x family (with Ambisafe-internal optimizer pass) |
| Optimizer | ON |
| Verification | Source reconstructed from decompilation + sibling-contract source (not byte-exact) |

## Contract

Elcoin (ELC) is the main token contract of the elCoin project, an Ethereum-based currency with a hybrid Proof-of-Stake + Proof-of-Transaction consensus model. The network's first transaction landed on Dec 12, 2015; this contract was deployed Jan 27, 2016 as the production token, replacing earlier test deployments.

The token uses the Ambisafe **Ambi** framework for multi-authority access control: the contract is registered under the name `"elcoin"` in an Ambi registry at `0xa95b9127e7102dcfa3869c47ee12a0ec85c261c5`, and permission checks iterate over the registered authorities for each role (`security`, `currencyOwner`, `pool`, `cron`). Balances live in an external `ElcoinDb` contract, addressed via `ambi.getNodeAddress("elcoinDb")`. PoS rewards are dispatched to `getNodeAddress("elcoinPoS")` after each transfer.

## Why this is a source reconstruction, not an exact-byte match

Four reasons stack to make exact-byte cracking infeasible without more time:

1. **The January 2016 source is not on GitHub.** The `ElcoinCurrency/ElcoinContract` repo's earliest commit is May 19, 2016. That repo's `Elcoin.sol` is a *successor* version (different Ambi interface, different role names, added PoT/treasury/gas-refund features, removed five admin functions). The deployed contract is 10,824 bytes; the May-2016 version compiles to 6,636 bytes — different shape entirely.

2. **An Ambisafe-internal solc optimizer pass.** The deployed bytecode encodes `"currencyOwner"` as `PUSH13 0x31bab93932b731bca7bbb732b9 * 2^153` (since `0x31bab93932b731bca7bbb732b9 << 153 == 0x63757272656e63794f776e6572 << 152`, both expand to the same bytes32). Likewise `"elcoinDb"` is encoded as `PUSH8 0x32b631b7b4b72231 * 2^193` instead of the natural `PUSH8 0x656c636f696e4462 * 2^192`. No standard solc 0.1.x / 0.2.x / 0.3.x release we tested emits this — it appears to be a custom Ambisafe build or an internal optimizer pass that never shipped publicly.

3. **A shared-modifier dispatch pattern.** Each access-controlled function entry pushes a return address and JUMPs to a single shared `getChildCount(name, role)` setup at `0x1431`. Standard solc 0.1.x inlines the modifier per call site instead, producing ~3× larger function entries.

4. **Decompiler hallucinations confused early reconnaissance.** Palkeoramix labels several functions with role strings (`"currencyOwner"`, `"elcoinDb"`, even `"elcoinPoT"`) whose literal bytes do not appear in the runtime. The actual strings *are* there — encoded via the optimizer trick above — but searching for them naively returns "not found".

We did, however, fully reverse-engineer the contract's surface: all 31 function selectors are accounted for, the Ambi v1 interface is recovered, the role-to-function mapping is verified by PUSH-occurrence counts, and the storage layout is known. The `Elcoin.sol` in this folder compiles cleanly under multiple solc 0.1.x–0.2.0 nightlies and produces a runtime that is structurally identical (same dispatcher, same 31 selectors, same external-call selectors, same event topics) but ~7 % larger due to the missing optimizer pass.

## Recovered Ambi v1 interface

```solidity
contract Ambi {
    function getNodeAddress(bytes32 _name) constant returns (address);                              // 0x2ade6c36
    function addNode(bytes32 _name, address _addr) external returns (bool);                        // 0x76849376
    function getChildCount(bytes32 _name, bytes32 _role) constant returns (uint);                  // 0xa09a4221
    function getChildAddress(bytes32 _name, bytes32 _role, uint8 _idx) constant returns (address); // 0xa6a8cc00
}
```

The `getChildCount` + `getChildAddress` pair is the **v1** iteration API. By the May 2016 commit, Ambisafe had switched to a single `hasRelation(bytes32,bytes32,address) constant returns (bool)` call (0xa1add510) — the v1 pair is gone from every public Ambisafe repo. The two selectors above did not appear in the 4byte directory at time of investigation, and brute-force selector search across ~10⁶ candidate function names was needed to identify them.

## Function selector map (31 total)

| Selector | Function | Role |
|----------|----------|------|
| `0x06fdde03` | `name()` | — |
| `0x095ea7b3` | `approve(address,uint256)` | `security` |
| `0x13c8a376` | `recovered(uint256)` | — |
| `0x18160ddd` | `totalSupply()` | — |
| `0x21f8a721` | `getAddress(bytes32)` | — |
| `0x23b872dd` | `transferFrom(address,address,uint256)` | `security` |
| `0x3751707c` | `ambi()` | — |
| `0x39e7fddc` | `feeAddr()` | — |
| `0x431e83ce` | `absMaxFee()` | — |
| `0x5b65b9ab` | `setFee(uint256,uint256,uint256)` | `cron` |
| `0x5b69f2ca` | `allowances(uint256)` | — |
| `0x6b3e7c2d` | `unapproveTo(address,address)` | `security` |
| `0x70a08231` | `balanceOf(address)` | — |
| `0x7948f523` | `setAmbiAddress(address,bytes32)` | — |
| `0x7fd6f15c` | `feePercent()` | — |
| `0x88d695b2` | `batchTransfer(address[],uint256[])` | `currencyOwner` |
| `0x93423e9c` | `getAccountBalance(address)` | — |
| `0x99a5d747` | `calculateFee(uint256)` | — |
| `0xa5f2a152` | `transferTo(address,address,uint256)` | `security` |
| `0xa7f43779` | `remove()` | (msg.sender == ambi) |
| `0xa9059cbb` | `transfer(address,uint256)` | `security` |
| `0xaa64c43b` | `transferPool(address,address,uint256)` | `pool` |
| `0xab77b178` | `issueCoin(address,uint256)` | `currencyOwner` |
| `0xace30883` | `absMinFee()` | — |
| `0xb2478cfe` | `recoveredIndex(address)` | — |
| `0xb2855b4f` | `setFeeAddr(address)` | `currencyOwner` |
| `0xbfcabc6b` | `allowanceTotal(address)` | — |
| `0xd6d0802a` | `allowanceIndex(bytes32)` | — |
| `0xdd62ed3e` | `allowance(address,address)` | — |
| `0xe312682a` | `approveAllowance(address,address,uint256)` | `currencyOwner` |
| `0xf5062732` | `approveTo(address,address,uint256)` | `security` |
| `0xfbf1f78a` | `unapprove(address)` | `security` |

## On-chain storage layout

| Slot | Type | Name |
|------|------|------|
| 0 | `address` | `ambi` (Ambi registry contract) |
| 1 | `bytes32` | `name` (this contract's name in the registry, `"elcoin"`) |
| 2 | `mapping(address => uint)` | `recoveredIndex` |
| 3 | `address[]` | `recovered` |
| 4 | `uint` | `totalSupply` |
| 5 | `uint` | `absMinFee` |
| 6 | `uint` | `feePercent` |
| 7 | `uint` | `absMaxFee` |
| 8 | `address` | `feeAddr` |
| 9 | `mapping(bytes32 => uint)` | `allowanceIndex` (keyed by `sha3(owner, spender)`) |
| 10 | `Allowance[]` | `allowances` (`struct Allowance { address owner; address spender; uint amount; }`) |

Constructor reads at deployment time confirm: slot 0 = `0xa95b9127e7102dcfa3869c47ee12a0ec85c261c5` (Ambi address), slot 1 = `0x656c636f696e0000...0000` (`"elcoin"` left-aligned).
