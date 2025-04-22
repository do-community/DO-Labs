'use client';

import { useState } from 'react';

export default function Home() {
  const [count, setCount] = useState(0);
  const [response, setResponse] = useState('');
  const [loading, setLoading] = useState(false);

  const handleClick = async () => {
    setLoading(true);
    try {
      const res = await fetch('http://localhost:3001/api/joke');
      const text = await res.text();
      console.log('✅ API response:', text);
      setResponse(text);
    } catch (err) {
      console.error('❌ API error:', err);
      setResponse('Error calling the API');
    } finally {
      setCount(prev => prev + 1);
      setLoading(false);
    }
  };

  return (
    <main style={{ padding: '2rem', color: 'white', backgroundColor: '#111', minHeight: '100vh' }}>
      <h1 style={{ fontSize: '1.5rem', marginBottom: '1rem' }}>
        Valkey Rate Limiting Demo
      </h1>

      <button
        onClick={handleClick}
        disabled={loading}
        style={{
          backgroundColor: '#222',
          color: loading ? '#888' : 'white',
          padding: '1rem 2rem',
          border: '1px solid #444',
          borderRadius: '8px',
          cursor: loading ? 'not-allowed' : 'pointer',
          marginBottom: '1rem',
        }}
      >
        {loading ? 'Loading...' : 'Get a Chuck Norris Joke'}
      </button>

      <p>Requests made: {count}</p>
      <p><strong>Response:</strong></p>
      <pre style={{ whiteSpace: 'pre-wrap' }}>{response}</pre>
    </main>
  );
}



