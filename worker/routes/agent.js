export async function handleAgent(request, env) {
  return new Response(
    JSON.stringify({ route: "agent", status: "ok" }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  )
}
