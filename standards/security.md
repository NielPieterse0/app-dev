# Security And Secrets Standard

- Never commit secrets, tokens, service-role keys, private certificates, or production `.env` files.
- Commit `.env.example` with variable names and safe placeholder values.
- Use least-privilege Supabase keys in clients. Supabase anon keys are client-safe when Row Level Security is correct; service role keys are server-only and must never be exposed through Vite, Expo, Next public variables, browser storage, or committed files.
- Require Row Level Security for every Supabase table that stores user, tenant, customer, financial, operational, or otherwise non-public data before production use.
- Keep long-lived privileged secrets out of browser storage. Store only short-lived client session material through the platform auth library unless an app-specific security review approves a different design.
- Treat Codex skills, hooks, and scripts as executable supply-chain artifacts. Keep them local, reviewed, and minimal.
- Require explicit user approval before destructive filesystem commands, publishing, production deploys, or schema migrations against live databases.
- Add dependency review, secret scanning, typecheck, lint, tests, and build checks in CI once a project moves beyond prototype stage.
- Treat production deploys and live database migrations as release operations. Record the target environment, command, expected effect, rollback path, and explicit user approval before running them.
- Review authentication, authorization, RLS policies, payment flows, public API routes, file uploads, and AI tool actions before production readiness.
