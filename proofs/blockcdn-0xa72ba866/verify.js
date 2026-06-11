// Self-contained: uses the bundled soljson compiler's own compileJSON entrypoint (no npm deps).
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const source = fs.readFileSync(path.join(__dirname, 'blockcdn.sol'), 'utf8');
const TARGET = fs.readFileSync(path.join(__dirname, 'target_runtime.txt'), 'utf8').trim().toLowerCase().replace(/^0x/, '');
const solc = require(path.join(__dirname, 'soljson-v0.4.2.js'));

const compileJSON = solc.cwrap('compileJSON', 'string', ['string', 'number']);
console.log('BlockCDN (BCDN) verification');
console.log('Contract: 0xa72ba8665992f2d48851bca8889e320f67b12557');
console.log('Compiler: soljson-v0.4.2+commit.af6afb04 (optimizer ON, runs 200)\n');

const out = JSON.parse(compileJSON(source, 1));
const C = out.contracts['blockcdn'] || out.contracts[':blockcdn'];
const runtime = (C.runtimeBytecode || '').toLowerCase();
const h = s => crypto.createHash('sha256').update(Buffer.from(s, 'hex')).digest('hex');
console.log(`Runtime: ${runtime.length/2} bytes  SHA-256: ${h(runtime)}`);
console.log(`Target:  ${TARGET.length/2} bytes  SHA-256: ${h(TARGET)}\n`);
if (runtime === TARGET) console.log('VERIFIED: exact bytecode match');
else { let i=0; while(i<runtime.length&&i<TARGET.length&&runtime[i]===TARGET[i])i++; console.log('FAIL at offset', Math.floor(i/2)); process.exit(1); }
