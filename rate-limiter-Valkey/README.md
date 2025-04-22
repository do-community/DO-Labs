# Rate Limiter with Valkey

A demonstration of rate limiting using Valkey (Redis-compatible database) with a modern web application. This project showcases how to implement efficient rate limiting for API endpoints using Valkey's atomic operations.

## Overview

This project consists of two main components:
- A backend API server (Node.js/Express) that implements rate limiting using Valkey
- A frontend application (Next.js) that demonstrates the rate limiting in action

### Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Frontend   │────▶│   Backend   │────▶│   Valkey    │
│  (Next.js)  │◀────│  (Express)  │◀────│  Database   │
└─────────────┘     └─────────────┘     └─────────────┘
```

### How Valkey Helps

Valkey (a Redis-compatible database) is used to implement efficient rate limiting through:
1. **Atomic Operations**: Using Lua scripts to ensure thread-safe rate limit counting
2. **TTL (Time-To-Live)**: Automatically expiring rate limit counters
3. **High Performance**: In-memory operations for fast rate limit checks
4. **Persistence**: Optional persistence of rate limit data

The rate limiter allows 5 requests per minute per IP address, demonstrating how to protect your API from abuse.

## Prerequisites

- Node.js (v18 or later)
- npm or yarn
- Valkey instance (local or cloud-based)
- Git

## Local Development Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/rate-limiter-Valkey.git
cd rate-limiter-Valkey
```

### 2. Set Up Environment Variables

Create a `.env` file in the `valkey-backend` directory:

```bash
cd valkey-backend
touch .env
```

Add the following variables to `.env`:
```
VALKEY_HOST=localhost
VALKEY_PORT=port_from_dashboard
VALKEY_PASSWORD=your_password
PORT=3001
```

### 3. Install Dependencies

Install backend dependencies:
```bash
npm install
```

Install frontend dependencies:
```bash
cd ../valkey-frontend
npm install
```

### 4. Start the Development Servers

In one terminal, start the backend:
```bash
cd valkey-backend
npm start
```

In another terminal, start the frontend:
```bash
cd valkey-frontend
npm run dev
```

### 5. Access the Application

- Frontend: http://localhost:3000
- Backend API: http://localhost:3001

## API Endpoints

- `GET /api/trending`: Fetches trending GitHub repositories (rate limited)
- `GET /api/ping`: Health check endpoint

## Rate Limiting Implementation

The rate limiter is implemented using a Lua script that:
1. Increments a counter for the client's IP
2. Sets an expiration time on first increment
3. Returns the current count
4. Blocks requests exceeding the limit (5 per minute)

```lua
local current
current = redis.call("INCR", KEYS[1])
if tonumber(current) == 1 then
  redis.call("EXPIRE", KEYS[1], ARGV[1])
end
return current
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
