import { callModel } from "../utils/ai.js"

export async function handleChat(request, env) {
  const body = await request.json().catch(() => ({}))
  const message = body.message || "Hello from Emo AI Pro"

  const reply = await callModel(env, message)

  return new Response(
    JSON.stringify({
      status: "ok",
      reply
    }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  )
}
