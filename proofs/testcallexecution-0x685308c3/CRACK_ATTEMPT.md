# TestCallExecution crack attempt notes

## Address
0x685308c340f91faea1b9263b2ebb9e71fc9a751d (deployed 2015-12-23 22:48 UTC)

## Result: NOT cracked

Closest compile is byte-length 3932 vs target 4005, with first divergence at byte 40.

## Setup tried

Reconstruction at `Testers_reconstructed.sol` merging:
- `TestCallExecution` from Testers.sol at v0.6.0 of pipermerriam/ethereum-alarm-clock
- Merged `register*` family of functions (originally in a separate `TestDataRegistry` contract)
  into TestCallExecution since the on-chain bytecode has them in one contract
- Reconstructed `scheduleSetBool(address,uint256,bool)` and `scheduleSetUInt(address,uint256,uint256)`
  by reading the on-chain dispatch table and disassembling the function bodies

## Selectors verified

All 33 selectors in the on-chain bytecode were matched against expected names via keccak256.
The schedule functions found in on-chain bytecode call:
```
to.call.value(msg.value)(0x01991313, address(this), bytes4(sha3("setBool()" | "setUInt(uint256)")), blockNumber)
```
where `0x01991313` is keccak256 selector of `scheduleCall(address,bytes4,uint256)`.

Followed by:
```
to.call(bytes4(sha3("registerData()")), value)
```
(no result check, no wasSuccessful update)

## Diff analysis

Using difflib on v0.1.6 opt=1 (also v0.1.7):

- mine = 3932 bytes, target = 4005 bytes (net -73 bytes; mine is missing code)
- First divergence at byte 40 (early in dispatch table)
- 5-byte insert at offset 392 (`6101009004` = PUSH2 0x0100, SWAP1, DIV) suggests storage packing differs
- 66-byte insert at offset 3755: shared cleanup blocks for wasSuccessful = 0/1/2 writes
- Schedule function: target uses combined memory area for both calls (one buffer build), mine emits two independent call blocks

## Likely cause

1. The actual deployed source bundles register and TestCallExecution differently or has additional
   shared cleanup paths (extra getter functions or different storage packing)
2. The schedule function in the original source likely uses a single inline assembly block or
   chained `.call.value()` syntax that triggers Solidity's buffer-sharing optimization, which my
   straightforward `if (!call) throw; call();` does not trigger

## What would crack it

The closest I could get was 73 bytes short with the right compiler (v0.1.6) and the right
function bodies. The remaining diff is in shared cleanup blocks and call-buffer layout that
depends on subtle source structure not recoverable from the bytecode alone.

Files saved:
- `Testers_reconstructed.sol`: best attempt source (close but not byte-identical)
