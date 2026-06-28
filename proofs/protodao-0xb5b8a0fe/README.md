# ProtoDAO — pre-TheDAO governance experiment

| Field | Value |
|-------|-------|
| Address | `0xb5b8a0fed80719cc3903cd5108e9a513949cfec6` |
| Deployed | Sep 24, 2015 (8 months before TheDAO) |
| Deployer | `0x7931c90100...` |
| Compiler | soljson v0.1.1+commit.6ff4cd6 |
| Optimizer | ON |
| Runtime | 2,244 bytes |
| Verification | `exact_bytecode_match` — byte-for-byte |

One of 10 byte-identical sibling deployments (chronological rank 1528–1537). Cracking this one verifies all ten.

## Verification

```bash
# with the soljson v0.1.1 legacy API (compile(source, 1) → optimized)
node -e 'const s=require("solc").setupMethods(require("./soljson-v0.1.1+commit.6ff4cd6.js"));
let r=JSON.parse(s.compile(require("fs").readFileSync("Democracy.sol","utf8"),1));
let bc=r.contracts.Democracy.bytecode; console.log(bc.slice(bc.indexOf("60606040",2)))'
```

Produces the 2,244-byte runtime in `onchain_runtime.hex` exactly.

## What it is

A hand-stripped fork of the Ethereum Foundation **"Democracy DAO"** from the go-ethereum
wiki Contract-Tutorial (the canonical proposals / quorum / debating-period governance demo).
Selectors and the three event topics (`ProposalAdded`, `Voted`, `ProposalTallied`) match the
wiki contract exactly, but the deployer simplified it:

- **No `voterShare.coinBalanceOf(...)` membership gates** — `newProposal`, `vote` and the
  `executeProposal` tally all dropped the external token-balance checks. The whole contract
  contains a single `CALL` (the identity-precompile memcpy used to copy the description string
  into the `ProposalAdded` log), not the wiki's token calls.
- **`voterShare` repurposed from a `token` address to a plain `uint`** vote weight
  (its getter has no address mask; the tally uses `voteWeight = voterShare`).
- **`executeProposal` reduced to tally + `active = false` + `ProposalTallied`** — no
  `quorum > minimumQuorum` check and no `recipient.call.value(amount)(data)` execution.
- `minimumQuorum` is declared but private and unused at runtime.

The trailing `STOP` byte before the appended `keccak256(3)` data constant is emitted by
**v0.1.1** specifically (v0.1.2+ drops it), which pins the compiler version even though the
deploy postdates the v0.1.1 release.

## Storage layout

| Slot | Type | Name |
|---|---|---|
| 0 | uint | debatingPeriod (public) |
| 1 | uint | voterShare (public) |
| 2 | address | founder (public) |
| 3 | Proposal[] | proposals (public) |
| 4 | uint | numProposals (public) |
| 5 | uint | minimumQuorum (private) |

`struct Proposal { address recipient; uint amount; bytes32 data; string description; uint creationDate; bool active; Vote[] votes; mapping(address=>bool) voted; }` (8-slot stride),
`struct Vote { int position; address voter; }`.
