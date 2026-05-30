# Sally, I love you (on-chain love letter)

| Field | Value |
|-------|-------|
| Address | `0xf0090f23ca64a12dd177d5bd47db02027669898c` |
| Deployed | April 28, 2018 (block 5,519,530) |
| Author | lex |
| Recipient | Sally (Chinese name 蔡世超) |
| Runtime size | 578 bytes |
| Function | bytes4 `0x0bd3daa4` returns the letter as a Solidity string |
| Verification | Unverified on Etherscan, but the runtime is entirely a constant-string return |

## What this contract is

A contract whose only on-chain purpose is to carry a love letter. The runtime returns a hard-coded Solidity string from a no-argument getter. The string is bilingual: a Mandarin Chinese pledge followed by an English summary.

## The letter

```
蔡世超，我爱你！自今起，我把对你的爱与祝福，镌刻到这区块链上，直到天荒地老，让世界一起见证。爱你的李捷。 Sally, I love you! From now on, I put my love and best bless to you on the chain, let whole world witness our loves, yours, lex
```

Recipient: 蔡世超 (Cài Shìchāo, English name Sally). Author: 李捷 (Lǐ Jié, English name lex).

## How to reproduce

```bash
curl -s -H 'User-Agent: Mozilla/5.0' -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"eth_call","params":[{"to":"0xf0090f23ca64a12dd177d5bd47db02027669898c","data":"0x0bd3daa4"},"latest"],"id":1}' \
  https://ethereum-rpc.publicnode.com | python3 -c "
import sys, json
r = json.load(sys.stdin)['result']
b = bytes.fromhex(r[2:])
off = int.from_bytes(b[0:32], 'big')
ln = int.from_bytes(b[off:off+32], 'big')
print(b[off+32:off+32+ln].decode())
"
```

## Files

- `letter.txt`, the decoded bilingual letter exactly as returned by the contract.
