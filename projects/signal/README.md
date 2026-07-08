# Signal

Signal is the first real app inside `app-dev`: a single-operator trend scouting dashboard that ranks public GitHub and Hacker News signals and persists source settings through a browser-safe Supabase boundary.

## Current app surface

- Ranked dashboard for GitHub and Hacker News source items.
- Settings workflow for source toggles and keyword filters.
- Local fallback persistence when Supabase is unconfigured or unavailable.
- Browser-safe Supabase integration that allows only publishable keys in the client.

Install dependencies inside `projects/signal` before verification:

```powershell
npm install
npm run typecheck
npm run lint
npm run test
npm run build
```

## Supabase notes

- Browser-facing Vite apps use `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY`.
- Do not expose `service_role`, secret, or backend-only Supabase keys in browser env.
- Enable Row Level Security on exposed schemas such as `public` before browser reads or writes.
- The current no-auth policies are an internal MVP compromise and are not safe for public launch.
- Auth, sharing, source-item persistence, and scheduled ingestion stay out of scope for Slice 2.
