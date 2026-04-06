const express = require('express');
const router = express.Router();

const COLOSSEUM_BASE = process.env.COLOSSEUM_COPILOT_API_BASE;
const COLOSSEUM_PAT = process.env.COLOSSEUM_COPILOT_PAT;

router.post('/query', async (req, res) => {
  const { query } = req.body;
  if (!query) return res.status(400).json({ error: 'Query is required' });

  try {
    const response = await fetch(`${COLOSSEUM_BASE}/query`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${COLOSSEUM_PAT}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ query }),
    });

    if (!response.ok) {
      const err = await response.text();
      return res.status(response.status).json({ error: err });
    }

    const data = await response.json();
    res.json(data);
  } catch (e) {
    console.error('Colosseum error:', e);
    res.status(500).json({ error: 'Research service unavailable' });
  }
});

router.get('/status', async (req, res) => {
  try {
    const response = await fetch(`${COLOSSEUM_BASE}/status`, {
      headers: { 'Authorization': `Bearer ${COLOSSEUM_PAT}` },
    });
    const data = await response.json();
    res.json(data);
  } catch (e) {
    res.status(500).json({ error: 'Cannot reach Colosseum' });
  }
});

module.exports = router;
