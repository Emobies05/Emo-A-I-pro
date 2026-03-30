🦋 Emo AI Pro — Flying Butterfly AI

Multi‑Model AI • Emotional Intelligence • Voice Chat • TheWall Web3 Integration

Emo AI Pro is a mobile‑first, emotionally intelligent AI assistant powered by a multi‑model backend (OpenAI, Gemini, Grok, Vercel AI).  
It features a flying butterfly companion with synchronized wing‑flap sound, animated UI, and deep emotional branding.

Built for real‑world use: fast, stable, expressive, and connected to TheWall Web3 ecosystem.

---

🦋 Features

AI Engine
- Multi‑model routing (OpenAI, Gemini, Grok, Vercel AI)
- Smart fallback logic
- Emotion‑aware responses
- Fast, low‑latency backend (Railway + Cloudflare Worker)

Voice Interaction
- Speech‑to‑Text (STT)
- Text‑to‑Speech (TTS)
- Natural conversational flow

Butterfly Companion
- Animated butterfly with smooth wing‑flap motion  
- Real wing‑flap sound (wing.wav)  
- Emotional presence that reacts to user input  
- TheWall‑themed butterfly branding

UI/UX
- Flutter‑Animate transitions  
- Clean chat interface  
- Mobile‑first design  
- Offline‑safe local storage (Shared Preferences)

Web3 Integration (TheWall)
- Zero‑seed‑phrase wallet  
- Multi‑chain support  
- Gasless transactions  
- AI‑powered wallet assistant  
- Charts, swaps, DApp browser  
- Secure, fast, user‑friendly

---

🧠 Architecture Overview

Frontend (Flutter)
- /lib/ contains UI, animations, chat logic  
- Uses http for backend communication  
- Assets:
  - assets/thewall_butterfly.png
  - assets/wing.wav

Backend (Node.js)
- /emo-ai-pro/ is the backend root  
- server.js handles:
  - Model routing  
  - Fallback logic  
  - Error handling  
  - Logging  
- Deployed on Railway  
- Exposed via Cloudflare Worker for global edge speed

Worker (Cloudflare)
- /worker/  
- Acts as a global proxy  
- Handles:
  - CORS  
  - Rate limiting  
  - Edge caching  
  - Secure key isolation  

---

🚀 Deployment

Railway Backend
Root Directory:
`
/emo-ai-pro
`

Start Command:
`
node server.js
`

Environment Variables:
`
PORT=8080
OPENAI_KEY=...
GEMINI_KEY=...
GROK_KEY=...
VERCEL_KEY=...
`

Cloudflare Worker
- Uses wrangler.toml
- Routes traffic to Railway backend
- Provides global edge acceleration

Flutter App
- Connects to Worker URL
- Mobile‑first, optimized for Android/iOS

---

📦 Installation (Flutter)

`bash
flutter pub get
flutter run
`

Dependencies used:

`
http
shared_preferences
speechtotext
flutter_tts
audioplayers
flutter_animate
`

---

🦋 Butterfly Identity
The butterfly is the emotional heart of Emo AI Pro.

It represents:
- Transformation  
- Lightness  
- Emotional presence  
- TheWall ecosystem identity  

The animation + sound effect creates a living AI companion feeling.

---

🛠 Project Structure

`
Emo-A-I-pro/
│
├── emo-ai-pro/          # Backend (Node.js)
│   ├── server.js
│   ├── routes/
│   ├── services/
│   └── package.json
│
├── worker/              # Cloudflare Worker
│   └── wrangler.toml
│
├── lib/                 # Flutter frontend
│   ├── ui/
│   ├── chat/
│   ├── animations/
│   └── main.dart
│
└── assets/
    ├── thewall_butterfly.png
    └── wing.wav
`

---

🔐 Security
- No seed phrases stored  
- No private keys exposed  
- Worker isolates API keys  
- Railway environment variables encrypted  
- HTTPS enforced end‑to‑end  

---

❤️ Made by Thewin
Built in Dubai.  
Built with emotion.  
Built for real users.

Emo AI Pro is not just an app — it’s a living AI companion with personality, presence, and emotional resonance.

---

🦋 Want a version with badges, emojis, or a dark theme?
Tell me your style and I’ll generate a second version.
