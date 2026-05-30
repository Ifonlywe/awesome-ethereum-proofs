const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const https = require('https');

const TARGET_RUNTIME = fs.readFileSync(path.join(__dirname, 'target_runtime.txt'), 'utf8').trim();
const SOURCE = fs.readFileSync(path.join(__dirname, 'Partnership.sol'), 'utf8');
const COMPILER_URL = 'https://binaries.soliditylang.org/bin/soljson-v0.3.2+commit.81ae2a78.js';
const COMPILER_FILE = path.join(__dirname, 'soljson-v0.3.2.js');

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

async function main() {
  console.log('Partnership Contract Verification');
  console.log('Contract: 0x12b0621d90c69867957a836d677c64c46ec4291d');
  console.log('Compiler: soljson-v0.3.2+commit.81ae2a78 (optimizer ON)');
  console.log();

  if (!fs.existsSync(COMPILER_FILE)) {
    console.log('Downloading compiler...');
    await download(COMPILER_URL, COMPILER_FILE);
  }

  const solc = require(COMPILER_FILE);
  const compile = solc.cwrap('compileJSON', 'string', ['string', 'number']);
  const out = JSON.parse(compile(SOURCE, 1));

  if (out.errors && out.errors.some(e => /error/i.test(e))) {
    console.log('COMPILE ERRORS:', out.errors);
    process.exit(1);
  }

  const runtime = (out.contracts['Partnership'].runtimeBytecode || '').toLowerCase();
  const target = TARGET_RUNTIME.toLowerCase();

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
    console.log('FAIL: bytecode mismatch');
    process.exit(1);
  }
}

main().catch(console.error);
