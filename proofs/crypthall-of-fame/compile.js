const fs = require('fs');
const path = require('path');

const solcVersion = process.argv[2] || 'v0.4.18+commit.9cf6e910';
const sourceFile = process.argv[3] || 'CryptoPokemons.sol';
const contractName = process.argv[4] || 'PokemonToken';
const optimize = process.argv[5] === '0' ? 0 : 1;

const solc = require('/tmp/soljson/node_modules/solc');
const soljson = require(`/tmp/soljson/soljson-${solcVersion}.js`);
const compiler = solc.setupMethods(soljson);

const source = fs.readFileSync(sourceFile, 'utf8');
const result = compiler.compile(source, optimize);

if (result.errors) {
  for (const e of result.errors) {
    console.error(e);
  }
}

if (!result.contracts || !result.contracts[':' + contractName]) {
  console.error('Contract not found. Available:', Object.keys(result.contracts || {}));
  process.exit(1);
}

const c = result.contracts[':' + contractName];
fs.writeFileSync('compiled_runtime.hex', c.runtimeBytecode);
fs.writeFileSync('compiled_creation.hex', c.bytecode);
console.log('Runtime length:', c.runtimeBytecode.length / 2);
console.log('Creation length:', c.bytecode.length / 2);
