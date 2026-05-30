# Mark H. Kane (on-chain obituary)

| Field | Value |
|-------|-------|
| Address | `0x5fa828e9eda730013fa49df9dab8261678833c0e` |
| Deployed | March 2018 (block 5,326,011) |
| Subject | Mark H. Kane, Richmond, October 24, 1950 to August 19, 2015 |
| Runtime size | 2,115 bytes |
| Verification | Unverified on Etherscan; runtime is a constant-string contract with 5 getters |

## What this contract is

A contract whose only purpose is to preserve an obituary on Ethereum. Five no-argument getters return the title, name, dates, biographical text, and a closing poem. The texts are baked into the runtime as Solidity string constants.

| Selector | Field |
|----------|-------|
| `0x422c4b05` | title ("In Loving Memory") |
| `0x17d7de7c` | name ("Mark H. Kane") |
| `0x16441813` | dates ("October 24, 1950 - August 19, 2015") |
| `0xe28a18f7` | obituary body |
| `0x951bdcde` | closing poem |

## The text

```
In Loving Memory

Mark H. Kane

October 24, 1950 - August 19, 2015

Mark Kane, a longtime Richmond resident, died suddenly surrounded by his loving family. A salesman for Leos Professional Audio for over 25 years, he was a lyrical songwriter and musician. Mark is survived by his wife of 10 years, Jinky and his daughter, Crystal. He leaves his sister, Mary Marshall, a nephew, Evan Marshall and two nieces, Christina Grappo and Kathryn Marshall. Mark was a devoted husband, father, brother, uncle, neighbor and friend.

Don't grieve for me, for now I'm free.
I took His hand when I heard him call.
I turned my back and left it all.
Then fill it with remembered joy.
My life's been full, I savored much.
Good friends, good times,
a loved one's touch.
A friendship shared, a laugh, a kiss.
Ah yes, these, I too, will miss.
Perhaps my time seemed all too brief.
Don't lengthen it now with undue grief.
Lift up your hearts and share with me.
God wanted me now, He set me free.
```

The closing verses are a known funerary poem, sometimes titled "He Is Gone" or "Don't Grieve For Me, For Now I'm Free."

Mark Kane died August 19, 2015, two and a half years before this contract was deployed. The family used Ethereum as a permanence layer for his memory.

## How to reproduce

```bash
for sel in 0x422c4b05 0x17d7de7c 0x16441813 0xe28a18f7 0x951bdcde; do
  curl -s -H 'User-Agent: Mozilla/5.0' -H 'Content-Type: application/json' \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"eth_call\",\"params\":[{\"to\":\"0x5fa828e9eda730013fa49df9dab8261678833c0e\",\"data\":\"$sel\"},\"latest\"],\"id\":1}" \
    https://ethereum-rpc.publicnode.com | python3 -c "
import sys, json
r = json.load(sys.stdin)['result']
b = bytes.fromhex(r[2:])
off = int.from_bytes(b[0:32], 'big')
ln = int.from_bytes(b[off:off+32], 'big')
print(b[off+32:off+32+ln].decode())
print()
"
done
```

## Files

- `obituary.txt`, all five fields concatenated as a single readable file.
