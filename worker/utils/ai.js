export async function callModel(env, prompt) {
  // Choose model (later we will make this dynamic)
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

// ----------------------------
// OPENAI
// ----------------------------
async function callOpenAI(env, prompt) {
  return `OpenAI placeholder response: ${prompt}`
}

// ----------------------------
// GEMINI
// ----------------------------
async function callGemini(env, prompt) {
  return `Gemini placeholder response: ${prompt}`
}

// ----------------------------
// GROK
// ----------------------------
async function callGrok(env, prompt) {
  return `Grok placeholder response: ${prompt}`
}

// ----------------------------
// VERCEL AI
// ----------------------------
async function callVercel(env, prompt) {
  return `Vercel AI placeholder response: ${prompt}`
}
