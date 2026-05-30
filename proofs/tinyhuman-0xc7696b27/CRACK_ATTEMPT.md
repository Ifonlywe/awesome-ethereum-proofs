# TinyHuman crack attempt notes

## Address
0xc7696b27830dd8aa4823a1cba8440c27c36adec4 (deployed 2015-10 by BlockApps)

## Result: NOT cracked

No serious reconstruction attempted, as Palkeoramix failed on 30/33 functions and the
contract's source is not published anywhere. Reconstructing 5,673 bytes of bytecode for
33 different functions (with custom royalty-splitting logic involving 8 hardcoded contributors,
USD pricing oracle integration, owner board governance, and per-stem purchase tracking) from
scratch is not feasible in the time budget.

## What would crack it

Either:
- Recovery of the original source from BlockApps' archives
- A 3-rd party decompilation tool that handles the 0.1.x bytecode style better than Palkeoramix
- Hand-disassembly and reconstruction of all 33 functions (multi-day effort)
