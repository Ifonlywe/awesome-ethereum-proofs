// TestCallExecution verification attempt
// Result: closest match is 73 bytes shorter than target (3932 vs 4005 bytes)
// See CRACK_ATTEMPT.md for full diff analysis.

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const https = require('https');

const SOURCE = fs.readFileSync(path.join(__dirname, 'Testers_reconstructed.sol'), 'utf8');

const COMPILER_URL = 'https://binaries.soliditylang.org/bin/soljson-v0.1.6+commit.d41f8b7c.js';
const COMPILER_FILE = path.join(__dirname, 'soljson-v0.1.6.js');

function download(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    https.get(url, res => {
      if (res.statusCode === 301 || res.statusCode === 302) {
        file.close();
        fs.unlinkSync(dest);
        return download(res.headers.location, dest).then(resolve).catch(reject);
      }
      res.pipe(file);
      file.on('finish', () => { file.close(); resolve(); });
    }).on('error', reject);
  });
}

async function fetchOnchain() {
  return new Promise((resolve, reject) => {
    const req = https.request({
      hostname: 'ethereum.publicnode.com', method: 'POST',
      headers: { 'Content-Type': 'application/json' },
    }, res => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => resolve(JSON.parse(data).result.slice(2)));
    });
    req.on('error', reject);
    req.write(JSON.stringify({ jsonrpc: '2.0', method: 'eth_getCode', params: ['0x685308c340f91faea1b9263b2ebb9e71fc9a751d', 'latest'], id: 1 }));
    req.end();
  });
}

async function main() {
  console.log('TestCallExecution verification attempt');
  console.log('Contract: 0x685308c340f91faea1b9263b2ebb9e71fc9a751d');
  console.log('Compiler: soljson-v0.1.6+commit.d41f8b7c (optimizer ON)');
  console.log();

  if (!fs.existsSync(COMPILER_FILE)) {
    console.log('Downloading compiler...');
    await download(COMPILER_URL, COMPILER_FILE);
  }

  const target = (await fetchOnchain()).toLowerCase();

  const solc = require(COMPILER_FILE);
  const compile = solc.cwrap('compileJSON', 'string', ['string', 'number']);
  const out = JSON.parse(compile(SOURCE, 1));
  if (out.errors && out.errors.some(e => /error/i.test(e) && !/warning/i.test(e))) {
    console.log('COMPILE ERRORS:', out.errors);
    process.exit(1);
  }

  const runtime = (out.contracts['TestCallExecution'].runtimeBytecode || '').toLowerCase();

  const runtimeHash = crypto.createHash('sha256').update(Buffer.from(runtime, 'hex')).digest('hex');
  const targetHash = crypto.createHash('sha256').update(Buffer.from(target, 'hex')).digest('hex');

  console.log(`Runtime: ${runtime.length / 2} bytes`);
  console.log(`Target:  ${target.length / 2} bytes`);
  console.log(`Runtime SHA-256: ${runtimeHash}`);
  console.log(`Target  SHA-256: ${targetHash}`);
  console.log();

  if (runtime === target) {
    console.log('VERIFIED: exact bytecode match');
  } else {
    let cp = 0;
    while (cp < runtime.length && cp < target.length && runtime[cp] === target[cp]) cp++;
    console.log('FAIL: bytecode mismatch');
    console.log(`First divergence at byte offset ${cp / 2}`);
    console.log('See CRACK_ATTEMPT.md for full analysis');
    process.exit(1);
  }
}

main().catch(console.error);
