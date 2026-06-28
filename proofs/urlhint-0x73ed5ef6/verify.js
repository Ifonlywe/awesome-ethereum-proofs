#!/usr/bin/env node
// Verify URLhint: on-chain runtime == go-ethereum's hardcoded UrlHintCode (byte-exact).
// Usage: node verify.js
const https = require('https');

const ADDR = '0x73ed5ef6c010727dfd2671dbb70faac19ec18626';

// UrlHintCode from go-ethereum common/registrar/contracts.go (creation bytecode).
// Runtime = slice after the deploy preamble `...6000396000f300`.
const URL_HINT_CODE =
  '0x60c180600c6000396000f30060003560e060020a90048063300a3bbf14601557005b' +
  '6024600435602435604435602a565b60006000f35b6000600084815260200190815260' +
  '200160002054600160a060020a0316600014806078575033600160a060020a03166000' +
  '600085815260200190815260200160002054600160a060020a0316145b607f5760bc56' +
  '5b336000600085815260200190815260200160002081905550806001600085815260200' +
  '190815260200160002083610100811060b657005b01819055505b50505056';

function rpc(method, params) {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify({ jsonrpc: '2.0', id: 1, method, params });
    const req = https.request('https://ethereum-rpc.publicnode.com', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
    }, res => { let d = ''; res.on('data', c => d += c); res.on('end', () => resolve(JSON.parse(d).result)); });
    req.on('error', reject); req.write(body); req.end();
  });
}

(async () => {
  const onchain = (await rpc('eth_getCode', [ADDR, 'latest'])).replace(/^0x/, '');
  const gethCreation = URL_HINT_CODE.replace(/^0x/, '');
  const gethRuntime = gethCreation.slice(gethCreation.indexOf('6000396000f300') + 14);

  console.log('on-chain runtime    :', onchain.length / 2, 'bytes');
  console.log('go-ethereum runtime :', gethRuntime.length / 2, 'bytes');
  const match = onchain === gethRuntime;
  console.log(match ? '\n✅ EXACT MATCH — on-chain == go-ethereum UrlHintCode' :
                      '\n❌ MISMATCH');
  process.exit(match ? 0 : 1);
})();
