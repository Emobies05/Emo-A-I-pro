export async function handleChat(request, env) {
  const body = await request.json().catch(() => ({}))
  const message = body.message || "Hello from Emo AI Pro"

  return new Response(
    JSON.stringify({
      status: "ok",
      reply: `You said: ${message}`
    }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  )
}
