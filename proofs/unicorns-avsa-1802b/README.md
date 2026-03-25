# Unicorns Token (MyToken) - 1802-byte variant - Source Reconstruction

Two ERC-20 token contracts deployed by avsa (Alex Van de Sande, `0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb`) on February 11, 2016. Both use the name "Unicorns" with symbol U+1F984 (unicorn emoji), deployed as test tokens during early Ethereum development. These are siblings of the 1830-byte Unicorns family (see `proofs/unicorns-token/`), differing only by the absence of a payable fallback function.

## Instances

| Instance | Address | Block | centralMinter |
|----------|---------|-------|---------------|
| A | [`0xe36905580fa8cc3006c14bafab9d0ecf39c9c124`](https://ethereumhistory.com/contract/0xe36905580fa8cc3006c14bafab9d0ecf39c9c124) | 988921 | `0x0` (deployer) |
| B | [`0xab15f08da9b99cbd2f71922953af9a38942d05ec`](https://ethereumhistory.com/contract/0xab15f08da9b99cbd2f71922953af9a38942d05ec) | 988935 | `0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359` |

Both instances have identical runtime bytecode. Creation bytecode differs only in ABI-encoded constructor arguments (centralMinter field).

## Verification

| Field | Value |
|-------|-------|
| Compiler | Solidity ~v0.1.2 (unknown Mist/browser-solidity snapshot, optimizer ON) |
| Method | Source reconstructed (functional match, no exact compiler binary available) |
| Runtime | 1802 bytes |
| Creation A | 2574 bytes |
| Creation B | 2574 bytes |
| Runtime SHA-256 | `4fec9e5f6c0ba65aa6a0283a39ee25c2becbf9ffb1ca17fe898c9058f2ef6f95` |
| Creation A SHA-256 | `4c5e13f7e189b0cccf7ba8cdf89b08407e22bd608fa762cef5ef9fb5b61c445d` |
| Creation B SHA-256 | `072d5d31e2e61eeddaadebf2e8fc635bf1644921c8367f581bfde0e55e8a0e25` |
| Proved by | [@Neo](https://ethereumhistory.com/historian/neo-by-cart00n) |

## Source Reconstruction Notes

The source (`MyToken.sol`) was reconstructed by analyzing the on-chain bytecode. This is the same ethereum.org "Advanced Token" template as the 1830-byte Unicorns siblings, minus the payable fallback function. Key findings:

- **15 public functions**: name, symbol, decimals, totalSupply, balanceOf, owner, frozenAccount, allowance, spentAllowance, transfer, approve, transferFrom, mintToken, freezeAccount, transferOwnership
- **No payable fallback**: Unlike the 1830-byte variant, this version does not forward received ETH to the owner (28 bytes smaller)
- **Storage layout**: `owner` (slot 0), `name` (slot 1), `symbol` (slot 2), `decimals` (slot 3), `totalSupply` (slot 4), `balanceOf` (slot 5), `frozenAccount` (slot 6), `allowance` (slot 7), `spentAllowance` (slot 8)
- **Constructor**: Sets `owner = msg.sender` unconditionally, then overrides with `centralMinter` if non-zero
- **mintToken**: Emits `Transfer(owner, target, mintedAmount)` (single event, from=owner not from=0)
- **transferFrom**: Emits `Transfer(msg.sender, _to, _value)` (sender, not _from)
- **approve()**: Declares `returns (bool success)` but no explicit return statement
- **String getter**: Uses old Solidity v0.1.1/v0.1.2 string packing format (pre-v0.1.3 change)
- **Address masking**: Uses mask-first pattern (pre-v0.1.3 codegen change)

## Compiler Notes

The exact compiler binary is not available in solc-bin archives. Bytecode analysis shows:
- Old string getter pattern (35 extra bytes per string getter vs v0.1.3+)
- Mask-first address operation pattern (changed to caller-first in v0.1.3)
- `throw` keyword support (not available in soljson v0.1.1 or v0.1.2)

This combination points to a Mist wallet embedded browser-solidity snapshot from late 2015 / early 2016 that is not in the official solc-bin release archives. The same compiler was likely used for the 1830-byte Unicorns siblings deployed the same day.
