export async function handleChat(request, env) {
  return new Response(
    JSON.stringify({ route: "chat", status: "ok" }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  )
}
