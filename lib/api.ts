const API_BASE = process.env.NEXT_PUBLIC_API_BASE ?? 'https://api.thewall.ai';

export async function sendChat(message: string) {
  const res = await fetch(`${API_BASE}/chat`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ message }),
  });
  return res.json();
}
