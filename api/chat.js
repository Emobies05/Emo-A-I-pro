import fetch from 'node-fetch';

const GEMINI_KEY = process.env.GEMINI_API_KEY;
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON = process.env.SUPABASE_ANON_KEY;
const GEMINI_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${GEMINI_KEY}`;

async function validateEmoKey(emoKey) {
  try {
    const res = await fetch(
      `${SUPABASE_URL}/rest/v1/emo_keys?key=eq.${emoKey}&select=key`,
      {
        headers: {
          apikey: SUPABASE_ANON,
          Authorization: `Bearer ${SUPABASE_ANON}`,
        },
      }
    );
    const data = await res.json();
    return Array.isArray(data) && data.length > 0;
  } catch {
    return false;
  }
}

export default async function handler(req, res) {
  // CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, x-emo-key');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST')
    return res.status(405).json({ error: 'Method not allowed' });

  const emoKey = req.headers['x-emo-key'];
  const { message, language = 'en' } = req.body;

  if (!message) return res.status(400).json({ error: 'Message required' });

  // Validate Emo-Key
  if (!emoKey) return res.status(401).json({ error: 'Emo-Key required' });

  const isValid = await validateEmoKey(emoKey);
  if (!isValid) return res.status(403).json({ error: 'Invalid Emo-Key' });

  // System prompt
  const systemPrompt =
    language === 'en'
      ? 'You are Emo AI Pro, a compassionate emotional intelligence assistant. Be warm, supportive and insightful. Respond in English.'
      : 'You are Emo AI Pro, a compassionate emotional intelligence assistant. Be warm, supportive and insightful. Respond in the same language as the user.';

  try {
    const geminiRes = await fetch(GEMINI_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [
          {
            parts: [{ text: `${systemPrompt}\n\nUser: ${message}` }],
          },
        ],
        generationConfig: {
          temperature: 0.8,
          maxOutputTokens: 1024,
        },
      }),
    });

    const data = await geminiRes.json();
    const reply =
      data?.candidates?.[0]?.content?.parts?.[0]?.text ?? 'No response';

    return res.status(200).json({ success: true, reply });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
}
