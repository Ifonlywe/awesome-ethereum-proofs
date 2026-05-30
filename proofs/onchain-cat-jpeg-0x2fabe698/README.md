# IMG (on-chain cat JPEG)

| Field | Value |
|-------|-------|
| Address | `0x2fabe69843e9a74a35b89145cb52e5568986c7a1` |
| Deployed | Feb 10, 2018 (block 4,943,545) |
| Deployer | `0xd766d89d` |
| Compiler | v0.4.11+commit.68ef5810 |
| Verification | Etherscan verified (contract name `IMG`) |
| Image | 128x128 JFIF baseline JPEG, 1,138 bytes |
| Function | `read()` returns the bytes as a space-separated hex string |

## What this contract is

A single-function Solidity contract whose only state and only output is a hard-coded JPEG of a tabby cat. The image is encoded as a long hexadecimal text string in the runtime bytecode; calling `read()` returns that string. A reader takes the hex pairs, parses them back into bytes, and decodes a 1,138-byte JPEG.

In a survey of the 111,821 unique 2018 contract families in the local data lake, this was the only contract whose runtime contained a renderable image. Most "on-chain art" projects of the era pointed at IPFS or HTTP URLs that have since rotted; here the picture is the contract.

## Files

- `IMG.sol`, the Etherscan-verified source.
- `cat.jpg`, the JPEG reconstructed from a live `eth_call` to `read()`.

## How to reproduce

```bash
# Call read() on mainnet
curl -s -H 'User-Agent: Mozilla/5.0' -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"2.0","method":"eth_call","params":[{"to":"0x2fabe69843e9a74a35b89145cb52e5568986c7a1","data":"0x57de26a4"},"latest"],"id":1}' \
  https://ethereum-rpc.publicnode.com | python3 -c "
import sys, json
r = json.load(sys.stdin)['result']
b = bytes.fromhex(r[2:])
offset = int.from_bytes(b[0:32], 'big')
length = int.from_bytes(b[offset:offset+32], 'big')
text = b[offset+32:offset+32+length].decode()
open('cat.jpg', 'wb').write(bytes.fromhex(text.replace(' ', '')))
"
file cat.jpg
# cat.jpg: JPEG image data, JFIF standard 1.01, ... 128x128, components 3
```
