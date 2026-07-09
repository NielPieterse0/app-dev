# Signal

Signal is the first real app inside `app-dev`: a single-operator trend scouting dashboard that ranks public GitHub and Hacker News signals, persists settings and live source items through a browser-safe remote boundary, and promotes strong signals into concept drafts for future product work.

## Current app surface

- Ranked dashboard for GitHub and Hacker News source items.
- Settings workflow for source toggles and keyword filters.
- Concept promotion, concept editing, and export workflow for future product briefs.
- Local fallback persistence when the configured remote backend is unavailable.
- Browser-safe Supabase integration that allows only publishable keys in the client.

Install dependencies inside `projects/signal` before verification:

```powershell
npm install
npm run typecheck
npm run lint
npm run test
npm run build
npm run e2e
npm run release:check
../../scripts/verify-app.ps1 -ProjectPath .
```

## Supabase notes

- Browser-facing Vite apps use `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY`.
- `VITE_GITHUB_TOKEN` is optional for internal operator use when unauthenticated GitHub Search rate limits become too restrictive. It is exposed to the browser bundle, so do not treat it as a public-launch solution.
- Do not expose `service_role`, secret, or backend-only Supabase keys in browser env.
- Enable Row Level Security on exposed schemas such as `public` before browser reads or writes.
- The current no-auth policies are an internal MVP compromise and are not safe for public launch.
- Live Slice 4 verification was completed against the bounded internal Supabase project `qwtfvuwkxtucgcteisfa`, including settings, feed, and concept RPC smoke checks.
- Auth, sharing, scheduled/background ingestion, and public launch remain out of scope for the current internal MVP.
