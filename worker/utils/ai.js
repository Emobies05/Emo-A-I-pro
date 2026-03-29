// ==========================================
// AI MODEL ROUTER
// ==========================================
export async function callModel(env, prompt) {
  // For now we hardcode OpenAI
  // Later we will make this dynamic based on user mode
  const model = "openai"

  if (model === "openai") {
    return await callOpenAI(env, prompt)
  }

  if (model === "gemini") {
    return await callGemini(env, prompt)
  }

  if (model === "grok") {
    return await callGrok(env, prompt)
  }

  if (model === "vercel") {
    return await callVercel(env, prompt)
  }

  return "No model selected"
}



// ==========================================
// OPENAI — REAL API CALL
// ==========================================
async function callOpenAI(env, prompt) {
  const apiKey = env.OPENAI_API_KEY

  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${apiKey}`
    },
    body: JSON.stringify({
      model: "gpt-4o-mini",
      messages: [
        { role: "user", content: prompt }
      ]
    })
  })

  const data = await response.json().catch(() => null)

  if (!data || !data.choices) {
    return "OpenAI error or empty response"
  }

  return data.choices[0].message.content
}



// ==========================================
// GEMINI — REAL API CALL
// ==========================================
async function callGemini(env, prompt) {
  const apiKey = env.GEMINI_API_KEY

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        contents: [
          {
            parts: [{ text: prompt }]
          }
        ]
      })
    }
  )

  const data = await response.json().catch(() => null)

  if (!data || !data.candidates || !data.candidates[0]) {
    return "Gemini error or empty response"
  }

  return data.candidates[0].content.parts[0].text
}

// ==========================================
// GROK — REAL API CALL (xAI)
// ==========================================
async function callGrok(env, prompt) {
  const apiKey = env.GROK_API_KEY

  const response = await fetch("https://api.x.ai/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${apiKey}`
    },
    body: JSON.stringify({
      model: "grok-2-latest",
      messages: [
        { role: "user", content: prompt }
      ]
    })
  })

  const data = await response.json().catch(() => null)

  if (!data || !data.choices) {
    return "Grok error or empty response"
  }

  return data.choices[0].message.content
}



// ==========================================
// VERCEL AI — Placeholder (real API next)
// ==========================================
async function callVercel(env, prompt) {
  return `Vercel AI placeholder response: ${prompt}`
}
