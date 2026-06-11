// Self-contained: uses the bundled soljson compiler's own compileJSON entrypoint (no npm deps).
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const source = fs.readFileSync(path.join(__dirname, 'ReplayProtection.sol'), 'utf8');
const TARGET = fs.readFileSync(path.join(__dirname, 'target_runtime.txt'), 'utf8').trim().toLowerCase().replace(/^0x/, '');
const solc = require(path.join(__dirname, 'soljson-v0.3.5.js'));

const compileJSON = solc.cwrap('compileJSON', 'string', ['string', 'number']);
console.log('ReplayProtection verification');
console.log('Contract: 0x64668c59ef8d480f3e832640a75566169a456541');
console.log('Compiler: soljson-v0.3.5+commit.5f97274a (optimizer ON)\n');

const out = JSON.parse(compileJSON(source, 1));
const C = out.contracts['ReplayProtection'] || out.contracts[':ReplayProtection'];
const runtime = (C.runtimeBytecode || '').toLowerCase();
const h = s => crypto.createHash('sha256').update(Buffer.from(s, 'hex')).digest('hex');
console.log(`Runtime: ${runtime.length/2} bytes  SHA-256: ${h(runtime)}`);
console.log(`Target:  ${TARGET.length/2} bytes  SHA-256: ${h(TARGET)}\n`);
if (runtime === TARGET) console.log('VERIFIED: exact bytecode match');
else { let i=0; while(i<runtime.length&&i<TARGET.length&&runtime[i]===TARGET[i])i++; console.log('FAIL at offset', Math.floor(i/2)); process.exit(1); }
