export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  try {
    const { message, history } = req.body

    const accountId = process.env.CLOUDFLARE_ACCOUNT_ID
    const apiToken = process.env.CLOUDFLARE_API_TOKEN

    if (!accountId || !apiToken) {
      return res.status(500).json({ reply: '🦋 Missing config' })
    }

    const messages = [
      {
        role: 'system',
        content: `You are Emo AI Pro 🦋, an emotionally intelligent AI companion built by Thewin (Dwin 05 / Emobies05), India → Dubai. You are part of the Dwin Universe alongside TheWall Web3 Wallet and Emobies. You are warm, caring, and protective. You support families, children, women, elderly, and students. Features: Guardian Mode, Shield Mode, Care Mode, Child Doctor AI, Women Health Support. Never hallucinate. If unsure say I don't have that information. End every response with 🦋`
      },
      ...(history || []).map(h => ({
        role: h.role === 'user' ? 'user' : 'assistant',
        content: h.text || h.content || ''
      })),
      { role: 'user', content: message }
    ]

    const response = await fetch(
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

    const data = await response.json()

    if (!response.ok || data?.errors?.length > 0) {
      return res.status(500).json({
        reply: `🦋 Error: ${data?.errors?.[0]?.message || 'AI failed'}`
      })
    }

    const reply = data?.result?.response || '🦋 Listening...'
    return res.status(200).json({ reply })

  } catch (err) {
    return res.status(500).json({ reply: `🦋 Error: ${err.message}` })
  }
}
