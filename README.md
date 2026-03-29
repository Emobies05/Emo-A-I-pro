# Emo AI Pro

Emo AI Pro is the unified backend for the entire Emobies ecosystem — powering
Emowall AI, TheWall Web3 Wallet, Emobies Repair, and all future AI‑driven
products.  
It combines Cloudflare Workers (global edge API) with a Python Agent (Railway)
to deliver a fast, scalable, multi‑model AI system.

---

## 🚀 Architecture

### **Cloudflare Worker (Node.js)**
- Global API layer
- Multi‑model routing (Grok, Gemini, OpenAI, Vercel AI)
- Memory system (KV + Vectorize)
- File storage (R2)
- Authentication & rate‑limits
- Connects to Python Agent for heavy tasks

### **Python Agent (Railway)**
- GitHub integration (PRs, code analysis, repo scanning)
- File processing
- Wallet logic analysis
- Repair workflow intelligence
- Long‑context reasoning

---

## 🧠 Features

- Multi‑model AI routing  
- Persistent memory  
- Vector search  
- GitHub automation  
- Secure API key management  
- Modular tools & modes  
- Real‑time reasoning via Python Agent  
- Cloudflare global edge performance  

---

## 🔧 Tech Stack

- **Cloudflare Workers**
- **Cloudflare KV / R2 / Vectorize**
- **Railway Python Agent**
- **Node.js**
- **Python 3**
- **GitHub API**
- **Grok / Gemini / OpenAI / Vercel AI**

---

## 🔐 Environment Variables

### Cloudflare Worker
