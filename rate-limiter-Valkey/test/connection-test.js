const fetch = require('node-fetch');

const url = 'http://localhost:3001/api/joke';

(async () => {
  for (let i = 1; i <= 10; i++) {
    const res = await fetch(url);
    const body = await res.text();
    console.log(`[${i}] Status: ${res.status} | Response: ${body}`);
  }
})();
