export async function handleResearch(request, env) {
  const json = (data, status = 200) =>
    new Response(JSON.stringify(data), {
      status,
      headers: { "Content-Type": "application/json" }
    })

  if (request.method === "GET") {
    try {
      const res = await fetch(`${env.COLOSSEUM_COPILOT_API_BASE}/status`, {
        headers: {
          "Authorization": `Bearer ${env.COLOSSEUM_COPILOT_PAT}`
        }
      })
      const data = await res.json()
      return json({ status: "ok", colosseum: data })
    } catch (e) {
      return json({ error: "Colosseum unreachable", detail: e.message }, 503)
    }
  }

  if (request.method === "POST") {
    const body = await request.json().catch(() => ({}))
    const query = body.query || ""

    if (!query.trim()) {
      return json({ error: "query is required" }, 400)
    }

    try {
      const res = await fetch(`${env.COLOSSEUM_COPILOT_API_BASE}/query`, {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${env.COLOSSEUM_COPILOT_PAT}`,
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ query })
      })

      if (!res.ok) {
        const err = await res.text()
        return json({ error: "Colosseum error", detail: err }, res.status)
      }

      const data = await res.json()
      return json({ status: "ok", query, result: data })
    } catch (e) {
      return json({ error: "Research failed", detail: e.message }, 500)
    }
  }

  return json({ error: "Method not allowed" }, 405)
}
