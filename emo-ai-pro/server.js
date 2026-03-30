import express from "express";
import axios from "axios";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());

// ------------------------------
// Fallback Chain
// ------------------------------
async function askEmoAIPro(prompt) {
  const chain = [callOpenAI, callGemini, callGrok, callVercel];

  for (const fn of chain) {
    try {
      const reply = await fn(prompt);
      if (reply) return reply;
    } catch (e) {}
  }

  return "All AI engines are temporarily unavailable. Please try again later.";
}

// ------------------------------
// Model Functions
// ------------------------------
async function callOpenAI(prompt) {
  const res = await axios.post(
    "https://api.openai.com/v1/chat/completions",
    {
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
    },
    {
      headers: { Authorization: `Bearer ${process.env.OPENAI_KEY}` },
    }
  );
  return res.data.choices[0].message.content;
}

async function callGemini(prompt) {
  const res = await axios.post(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${process.env.GEMINI_KEY}`,
    {
      contents: [{ parts: [{ text: prompt }] }],
    }
  );
  return res.data.candidates[0].content.parts[0].text;
}

async function callGrok(prompt) {
  const res = await axios.post(
    "https://api.x.ai/v1/chat/completions",
    {
      model: "grok-beta",
      messages: [{ role: "user", content: prompt }],
    },
    {
      headers: { Authorization: `Bearer ${process.env.GROK_KEY}` },
    }
  );
  return res.data.choices[0].message.content;
}

async function callVercel(prompt) {
  const res = await axios.post(
    "https://api.vercel.ai/v1/chat/completions",
    {
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
    },
    {
      headers: { Authorization: `Bearer ${process.env.VERCEL_KEY}` },
    }
  );
  return res.data.choices[0].message.content;
}

// ------------------------------
// Chat Route
// ------------------------------
app.post("/chat", async (req, res) => {
  const { message } = req.body;
  const reply = await askEmoAIPro(message);
  res.json({ reply });
});

// ------------------------------
// Start Server
// ------------------------------
app.listen(3000, () => {
  console.log("Emo-AI-Pro backend running on port 3000");
});
