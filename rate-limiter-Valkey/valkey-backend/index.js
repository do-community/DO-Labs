const fetch = (...args) => import('node-fetch').then(({ default: fetch }) => fetch(...args));
require('dotenv').config();
const express = require('express');
const Redis = require('ioredis');
const cors = require('cors');

const app = express();
app.use(cors());

const PORT = process.env.PORT || 3001;

// Log Valkey connection info
console.log("VALKEY_HOST:", process.env.VALKEY_HOST);
console.log("VALKEY_PORT:", process.env.VALKEY_PORT);
console.log("VALKEY_PASSWORD:", process.env.VALKEY_PASSWORD ? '✔️ present' : '❌ missing');

// Create Redis (Valkey) client
const redis = new Redis({
  host: process.env.VALKEY_HOST,
  port: Number(process.env.VALKEY_PORT),
  password: process.env.VALKEY_PASSWORD,
  tls: {}, // Required for DigitalOcean Valkey
});

// Lua script for atomic rate limiting
const rateLimiterLuaScript = `
  local current
  current = redis.call("INCR", KEYS[1])
  if tonumber(current) == 1 then
    redis.call("EXPIRE", KEYS[1], ARGV[1])
  end
  return current
`;

// Rate limiter middleware
const rateLimiter = async (req, res, next) => {
  const ip = req.ip || 'global';
  const limit = 5;
  const windowInSeconds = 60;
  const key = `rate:${ip}`;

  try {
    const current = await redis.eval(rateLimiterLuaScript, 1, key, windowInSeconds);
    console.log(`[RateLimit] IP: ${ip} - Count: ${current}`);

    if (current > limit) {
      return res.status(429).send('🚫 Rate limit exceeded. Please wait a minute.');
    }

    next();
  } catch (err) {
    console.error('[Valkey error]', err);
    res.status(500).send('Valkey error');
  }
};


// Chuck Norris joke route (rate limited)
app.get('/api/joke', rateLimiter, async (req, res) => {
  console.log("✅ Incoming request to /api/joke");

  try {
    const response = await fetch('https://api.chucknorris.io/jokes/random');
    const data = await response.json();
    console.log("✅ Joke fetched:", data.value);
    res.send(data.value);
  } catch (err) {
    console.error("❌ Failed to fetch joke:", err);
    res.status(500).send('Failed to fetch joke');
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`✅ API server running on http://localhost:${PORT}`);
});






