export async function handleGithub(request, env) {
  return new Response(
    JSON.stringify({ route: "github", status: "ok" }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  )
}
