// DAO Crowdfunding verification attempt
// Result: closest match is 1 byte longer than target (6245 vs 6244 bytes)
// See CRACK_ATTEMPT.md for full diff analysis.

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const https = require('https');

const TARGET_RUNTIME = fs.readFileSync(path.join(__dirname, 'target_runtime.txt'), 'utf8').trim();
const Token = fs.readFileSync(path.join(__dirname, 'Token_2015.sol'), 'utf8');
const Crowdfunding = fs.readFileSync(path.join(__dirname, 'Crowdfunding_2015.sol'), 'utf8');
const DAO = fs.readFileSync(path.join(__dirname, 'DAO_2015.sol'), 'utf8');

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

async function main() {
  console.log('DAO Crowdfunding verification attempt');
  console.log('Contract: 0x54715db7a8a57bc9bab660eb8e7b195774cb564d');
  console.log('Compiler: soljson-v0.1.6+commit.d41f8b7c (optimizer ON)');
  console.log();

  if (!fs.existsSync(COMPILER_FILE)) {
    console.log('Downloading compiler...');
    await download(COMPILER_URL, COMPILER_FILE);
  }

  const solc = require(COMPILER_FILE);
  const compile = solc.cwrap('compileJSON', 'string', ['string', 'number']);
  // Concatenate sources, strip imports
  const allSource = Token + '\n' +
    Crowdfunding.replace(/import\s+"[^"]+";\s*/g, '') + '\n' +
    DAO.replace(/import\s+"[^"]+";\s*/g, '');
  const out = JSON.parse(compile(allSource, 1));

  if (out.errors && out.errors.some(e => /error/i.test(e) && !/warning/i.test(e))) {
    console.log('COMPILE ERRORS:', out.errors);
    process.exit(1);
  }

  const runtime = (out.contracts['DAO'].runtimeBytecode || '').toLowerCase();
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
    let cp = 0;
    while (cp < runtime.length && cp < target.length && runtime[cp] === target[cp]) cp++;
    console.log('FAIL: bytecode mismatch');
    console.log(`First divergence at byte offset ${cp / 2}`);
    console.log('See CRACK_ATTEMPT.md for full analysis');
    process.exit(1);
  }
}

main().catch(console.error);
