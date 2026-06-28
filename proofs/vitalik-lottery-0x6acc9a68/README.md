# Vitalik's on-chain oracle (Serpent, Oct 2015)

**Verified by EthereumHistory (ethereumhistory.com)**

One of the earliest oracle implementations on Ethereum. Vitalik Buterin wrote it
in Serpent and deployed it on October 12, 2015. It lets a smart contract reach
data that lives outside the blockchain, something the EVM cannot do on its own.

## What it does

A smart contract has no way to read a web page or call an API. The EVM is sealed
off from the internet so that every node can re-run a transaction and agree on the
result. This contract is a small workaround for that limit, built out of two steps.

1. A user calls `call(fetcher, url, fetchId)` with the address of an off-chain
   data fetcher, the URL they want read, and an id of their own choosing. The
   contract hands the request to the fetcher and remembers which incoming request
   maps back to the user's `fetchId`.
2. The fetcher goes off-chain, retrieves the data, and comes back on-chain to call
   `callback(response, responseId)`. The contract looks up the original request and
   emits a `LogResponse` event carrying the fetched data, which the requesting user
   and any off-chain listener can then read.

That split, an on-chain request followed by an asynchronous on-chain callback, is
the request/callback pattern. It is exactly how oracles still work today.

## Why it matters

In late 2015 there was no Chainlink, and Oraclize (now Provable) was only just
appearing. Developers were still working out how a deterministic blockchain could
safely consume non-deterministic outside data. This contract is a tiny, hand-rolled
answer to that question, written by Ethereum's creator: split the work into a
request and a callback, and use events to deliver the result. The oracle pattern
that powers DeFi price feeds, insurance payouts, and prediction markets today
traces straight back to experiments like this one.

The full source is in [`caller.se`](caller.se).

---

## Verification details

| | |
|---|---|
| **Address** | [0x6acc9a6876739e9190d06463196e27b6d37405c6](https://ethereumhistory.com/contract/0x6acc9a6876739e9190d06463196e27b6d37405c6) |
| **Deployer** | 0x1db3439a222c519ab44bb1144fc28167b4fa6ee6 (Vitalik Buterin) |
| **Deployment tx** | 0x6b565bc0b6853b0c67570c50b8e233e4a0f53769c2fd476938e086b085d1eb50 |
| **Deployed** | Oct 12, 2015 (block 370,511) |
| **Language** | Serpent (Vitalik's own language), not Solidity |
| **Compiler** | ethereum/serpent commit f0b4128 (2015-10-15) |
| **Runtime** | 851 bytes, byte-for-byte exact match |
| **runtime sha256** | `9642ec35587703931a8adfc7d830b0e1e0e7eeb7a9e927d4837072d6fdfbd669` |

The source compiles to the on-chain bytecode exactly. Serpent commit f0b4128 also
matches at 146cc8a (2015-09-20); the later v2.0.7 does not (tighter codegen and
3 extra memory words push the runtime to 857 to 893 bytes). Solidity cannot produce
this bytecode in any version: the `600061027f53` init marker, the `5990590160009052`
memory allocator, the raw `LOG1` with a literal topic, and the identity-precompile
(0x04) memory copies are all Serpent idioms.

### Files

- `caller.se` original Serpent source (line 1 is the attribution comment, which the
  compiler strips, so it does not affect the bytecode)
- `target_runtime.txt` on-chain runtime (851 bytes hex)
- `target_creation.txt` on-chain creation bytecode (869 bytes hex)
- `creation_compiled.hex` full creation bytecode from the period compiler, identical to target
- `runtime_compiled.hex` runtime sliced from `creation_compiled.hex`, identical to target
- `verify.sh` recompiles in Docker and asserts the exact match

### Reproduce

```sh
./verify.sh
```

or manually:

```sh
docker run -d --platform linux/amd64 --name serpentbuild --entrypoint sleep serpent-compiler:latest infinity
docker cp caller.se serpentbuild:/caller.se
docker exec serpentbuild sh -c 'cd /serpent && git checkout -q f0b4128 && make serpentc >/dev/null && ./serpent compile /caller.se'
# runtime = creation[14 : 14+LEN], LEN from the 61<LEN>80 preamble (= 0x0353 = 851)
```
