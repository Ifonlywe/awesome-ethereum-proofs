const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const https = require('https');

const Token = fs.readFileSync(path.join(__dirname, 'Token.sol'), 'utf8');
const Crowdfunding = fs.readFileSync(path.join(__dirname, 'Crowdfunding.sol'), 'utf8');
const DAO = fs.readFileSync(path.join(__dirname, 'DAO.sol'), 'utf8');
const TARGET = fs.readFileSync(path.join(__dirname, 'target_runtime.txt'), 'utf8').trim().toLowerCase();

const COMPILER_VERSION = 'soljson-v0.1.7-nightly.2015.11.19+commit.58110b27.js';
const COMPILER_URL = 'https://binaries.soliditylang.org/bin/' + COMPILER_VERSION;
const COMPILER_FILE = path.join(__dirname, 'soljson-v0.1.7-nightly.js');

function download(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    https.get(url, res => {
      if (res.statusCode === 301 || res.statusCode === 302) {
        file.close(); try { fs.unlinkSync(dest); } catch(e) {}
        return download(res.headers.location, dest).then(resolve).catch(reject);
      }
      res.pipe(file);
      file.on('finish', () => { file.close(); resolve(); });
    }).on('error', reject);
  });
}

async function main() {
  console.log('DAO Crowdfunding verification');
  console.log('Contract: 0x54715db7a8a57bc9bab660eb8e7b195774cb564d');
  console.log('Compiler:', COMPILER_VERSION);
  console.log();
  if (!fs.existsSync(COMPILER_FILE)) {
    console.log('Downloading compiler...');
    await download(COMPILER_URL, COMPILER_FILE);
  }
  const solc = require(COMPILER_FILE);
  const compile = solc.cwrap('compileJSON', 'string', ['string', 'number']);
  const version = solc.cwrap('version', 'string', []);
  console.log('Loaded:', version());

  const allSource =
    Token + '\n' +
    Crowdfunding.replace(/import\s+"[^"]+";\s*/g, '') + '\n' +
    DAO.replace(/import\s+"[^"]+";\s*/g, '');

  const out = JSON.parse(compile(allSource, 1));
  if (out.errors && out.errors.some(e => /error/i.test(e) && !/warning/i.test(e))) {
    console.log('COMPILE ERRORS:'); for (const e of out.errors) console.log(' ', e);
    process.exit(1);
  }
  const runtime = (out.contracts['DAO'].runtimeBytecode || '').toLowerCase();
  const target = TARGET;

  const runtimeHash = crypto.createHash('sha256').update(Buffer.from(runtime, 'hex')).digest('hex');
  const targetHash  = crypto.createHash('sha256').update(Buffer.from(target,  'hex')).digest('hex');

  console.log(`Runtime: ${runtime.length / 2} bytes  SHA-256: ${runtimeHash}`);
  console.log(`Target:  ${target.length  / 2} bytes  SHA-256: ${targetHash }`);

  if (runtime === target) {
    console.log();
    console.log('VERIFIED: exact bytecode match');
  } else {
    let cp = 0;
    while (cp < runtime.length && cp < target.length && runtime[cp] === target[cp]) cp++;
    console.log('FAIL: bytecode mismatch at offset', Math.floor(cp/2));
    process.exit(1);
  }
}
main().catch(e => { console.error(e); process.exit(1); });
