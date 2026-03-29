// worker/index.js

import { handleChat } from "./routes/chat.js"
import { handleMode } from "./routes/mode.js"
import { handleMemory } from "./routes/memory.js"
import { handleTools } from "./routes/tools.js"
import { handleAgent } from "./routes/agent.js"
import { handleGithub } from "./routes/github.js"

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url)
    const path = url.pathname

    // JSON helper
    const json = (data, status = 200) =>
      new Response(JSON.stringify(data), {
        status,
        headers: { "Content-Type": "application/json" }
      })

    // Routing table
    const routes = {
      "/chat": () => handleChat(request, env),
      "/mode": () => handleMode(request, env),
      "/memory": () => handleMemory(request, env),
      "/tools": () => handleTools(request, env),
      "/agent": () => handleAgent(request, env),
      "/github": () => handleGithub(request, env)
    }

    // Match route
    if (routes[path]) {
      try {
        return await routes[path]()
      } catch (err) {
        return json({ error: err.message }, 500)
      }
    }

    // Default response
    return json({
      status: "Emo AI Pro Backend Running",
      routes: Object.keys(routes)
    })
  }
}
