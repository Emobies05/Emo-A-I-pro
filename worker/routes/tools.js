export async function handleTools(request, env) {
  return new Response(
    JSON.stringify({ route: "tools", status: "ok" }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  )
}
