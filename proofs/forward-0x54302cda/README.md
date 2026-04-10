# Forward Contract Verification

Bytecode verification proof for a simple ETH forwarding contract that sends received ETH to a specified address.

## Contract

| Field | Value |
|-------|-------|
| Address | `0x54302cdad49413689aca2a6fb49161e5b56faf4a` |
| Deployed | Aug 13, 2015 (block 81,753) |
| Compiler | soljson-v0.1.1+commit.6ff4cd6 (also matches all native C++ solc 0.1.0 and 0.1.1 builds) |
| Optimizer | OFF |
| Runtime | 155 bytes |
| Creation | 172 bytes (17 bytes init + 155 bytes runtime) |
| Runtime SHA-256 | `ff55869b252b117ae192404e9b70c3094f409b86d345c05ba89a2df3c607ea16` |
| Creation SHA-256 | `40fadba669ac7556a59ffa9830d886bba3737732498174421ec352607d72b09a` |
| Proved by | [@gpersoon](https://www.ethereumhistory.com/historian/169) |

## Details

| Field | Value |
|-------|-------|
| Functions | `forward(address)` |
| Constructor args | none |
| Pattern | ETH forwarder |

## Verification

node verify.js

The script downloads soljson-v0.1.1, compiles `Forward.sol` with optimizer OFF, and compares the output byte-for-byte against the on-chain creation bytecode. No native compiler or Docker required.

## Source

contract Forward {
    function forward(address account) returns (bool) {
        return account.send(msg.value);
    }
}
