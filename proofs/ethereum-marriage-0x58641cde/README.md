# Ethereum Marriage — first on-chain marriage registry

| Field | Value |
|-------|-------|
| Address | `0x58641cded077270a319f509e0266e96837cc79f4` |
| Deployed | Jan 2, 2016 |
| Deployer | hudson.eth (Hudson Jameson / "Souptacular") |
| Compiler | soljson v0.1.5+commit.23865e39 (optimizer ON) |
| Optimizer | ON |
| Runtime | 1,378 bytes |
| Verification | `exact_bytecode_match` — byte-for-byte |

The first marriage recorded on Ethereum. The published source in `Souptacular/marriage-dapp`
is a **later, revised** deployment; this original on-chain version was never published and is
reconstructed here.

Byte-identical output is produced by any no-hashing-indexed-bytes soljson in the
**v0.1.4-nightly … v0.1.6** window (v0.1.4-nightly.2015.10.6, v0.1.5, v0.1.5-nightly,
v0.1.6-nightly.2015.11.2 all match exactly). v0.1.7+ began keccak-hashing indexed `bytes`
event arguments, which this contract does not do — pinning the compiler to ≤ v0.1.6 despite the
Jan-2016 deploy date (period browser-solidity bundled an older soljson).

## Verification

```bash
node -e 'const s=require("solc").setupMethods(require("./soljson-v0.1.5+commit.23865e39.js"));
let r=JSON.parse(s.compile(require("fs").readFileSync("Marriage.sol","utf8"),1));
let bc=r.contracts.Marriage.bytecode; console.log(bc.slice(bc.indexOf("60606040",2)))'
```

Produces the 1,378-byte runtime in `onchain_runtime.hex` exactly.

## How it differs from the published (revised) marriage.sol

- `MajorEvent` 4th arg is **`bytes`** (not `bytes32`) — event topic
  `0x347d88e5…` = `MajorEvent(uint256,uint256,bytes32,bytes)`. Both `name` and `description`
  are indexed, but ≤v0.1.6 logs the indexed `bytes` as a single word **without hashing** (LOG3,
  no SHA3 in `majorEvent`/`createMarriage`).
- `majorEvent(bytes32 name, bytes description, uint256 eventTimeStamp)` — renamed from
  `majorEventFunc` and re-ordered/re-typed.
- The setters (`setStatus`, `setImage`, `marriageProof`) are **bare** — no `onlyowner`
  modifier and no event emission (the revised version emits on every setter).
- `owner` is **private** (no `owner()`/`getOwner()` getter).
- `returnFunds()` added, ungated: `var b = this.balance; owner.send(b);`. The temp local is
  required so `this.balance` is evaluated before `owner` (matches the on-chain operand order).
- Empty default fallback (`STOP`), not `throw`.

## Storage layout

| Slot | Type | Name |
|---|---|---|
| 0 | address | owner (private) |
| 1 | bytes32 | partner1 (public) |
| 2 | bytes32 | partner2 (public) |
| 3 | uint256 | marriageDate (public) |
| 4 | bytes32 | marriageStatus (public) |
| 5 | bytes | imageHash (public) |
| 6 | bytes | marriageProofDoc (public) |
