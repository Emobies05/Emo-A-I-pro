export async function handleChat(request, env) {
  const body = await request.json()

  return new Response(
    JSON.stringify({
      message: "Chat route working",
      received: body
    }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  )
}
