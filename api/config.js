export default function handler(req, res) {
  const url = process.env.SUPABASE_URL;
  const anonKey = process.env.SUPABASE_ANON_KEY;

  if (!url || !anonKey) {
    return res.status(500).json({ error: 'Supabase env vars not set' });
  }

  res.setHeader('Cache-Control', 's-maxage=3600');
  res.json({ url, anonKey });
}
