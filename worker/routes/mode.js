export async function handleMode(request, env) {
  return new Response(
    JSON.stringify({ route: "mode", status: "ok" }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  )
}
