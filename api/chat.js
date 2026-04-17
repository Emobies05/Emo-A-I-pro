export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    const { message, history, mode } = req.body

    const accountId = process.env.CLOUDFLARE_ACCOUNT_ID
    const apiToken = process.env.CLOUDFLARE_API_TOKEN
    const geminiKey = process.env.GEMINI_API_KEY
    const anthropicKey = process.env.ANTHROPIC_API_KEY

    // Auto-detect mode from message
    const detectedMode = mode || detectMode(message)

    let reply = ''

    if (detectedMode === 'image') {
      reply = await generateImage(message, accountId, apiToken)
    } else if (detectedMode === 'translate') {
      reply = await translateText(message, geminiKey, accountId, apiToken)
    } else if (detectedMode === 'code') {
      reply = await codeAssist(message, history, anthropicKey, accountId, apiToken)
    } else {
      reply = await chatGeneral(message, history, accountId, apiToken)
    }

    return res.status(200).json({ reply, mode: detectedMode })

  } catch (err) {
    return res.status(500).json({ reply: `🦋 Error: ${err.message}` })
  }
}

function detectMode(message) {
  const m = message.toLowerCase()
  if (m.includes('translate') || m.includes('in french') || m.includes('in spanish') || m.includes('in arabic') || m.includes('in hindi')) return 'translate'
  if (m.includes('generate image') || m.includes('draw') || m.includes('create image') || m.includes('make image')) return 'image'
  if (m.includes('code') || m.includes('function') || m.includes('debug') || m.includes('error') || m.includes('program') || m.includes('script')) return 'code'
  return 'general'
}

async function chatGeneral(message, history, accountId, apiToken) {
  const messages = [
    {
      role: 'system',
      content: 'You are Emo AI Pro 🦋, an emotionally intelligent AI companion built by Thewin (Dwin 05). You are warm, caring, protective and futuristic. Part of the Dwin Universe. Never hallucinate. End every response with 🦋'
    },
    ...(history || []).map(h => ({
      role: h.role === 'user' ? 'user' : 'assistant',
      content: h.text || h.content || ''
    })),
    { role: 'user', content: message }
  ]

  const res = await fetch(
    `https://api.cloudflare.com/client/v4/accounts/${accountId}/ai/run/@cf/meta/llama-3.1-8b-instruct`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ messages })
    }
  )
  const data = await res.json()
  return data?.result?.response || '🦋 Listening...'
}

async function codeAssist(message, history, anthropicKey, accountId, apiToken) {
  // Use Claude if available, fallback to Llama
  if (anthropicKey) {
    const messages = [
      ...(history || []).map(h => ({
        role: h.role === 'user' ? 'user' : 'assistant',
        content: h.text || h.content || ''
      })),
      { role: 'user', content: message }
    ]

    const res = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': anthropicKey,
        'anthropic-version': '2023-06-01',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 2048,
        system: 'You are Emo AI Pro coding assistant 🦋, built by Thewin (Dwin 05). You are an expert programmer. Give clear, working code with explanations. End every response with 🦋',
        messages
      })
    })
    const data = await res.json()
    return data?.content?.[0]?.text || '🦋 Listening...'
  }

  // Fallback to Llama
  return await chatGeneral(`You are an expert coding assistant. ${message}`, history, accountId, apiToken)
}

async function translateText(message, geminiKey, accountId, apiToken) {
  if (geminiKey) {
    const res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${geminiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: message }] }]
        })
      }
    )
    const data = await res.json()
    return data?.candidates?.[0]?.content?.parts?.[0]?.text || '🦋 Translation failed'
  }

  return await chatGeneral(`Translate this: ${message}`, [], accountId, apiToken)
}

async function generateImage(message, accountId, apiToken) {
  const prompt = message.replace(/generate image|draw|create image|make image/gi, '').trim()

  const res = await fetch(
    `https://api.cloudflare.com/client/v4/accounts/${accountId}/ai/run/@cf/stabilityai/stable-diffusion-xl-base-1.0`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${apiToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ prompt })
    }
  )

  if (res.ok) {
    const buffer = await res.arrayBuffer()
    const base64 = Buffer.from(buffer).toString('base64')
    return `IMAGE:data:image/png;base64,${base64}`
  }

  return '🦋 Image generation failed. Try again!'
}
