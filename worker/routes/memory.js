export async function handleMemory(request, env) {
  return new Response(
    JSON.stringify({ route: "memory", status: "ok" }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  )
}
