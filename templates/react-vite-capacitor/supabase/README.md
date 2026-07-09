# Supabase Scaffold

Generated apps start with this tracked `supabase/` folder so auth, RLS, and migration work do not stay implicit.

Use this scaffold as the starting point, then replace or extend it with the product-specific schema, policies, RPCs, and seed data your app actually needs.

Default expectations:

- Browser apps use only publishable Supabase keys in `.env`.
- Authenticated access is the default posture for mutable data paths.
- Anonymous write access is not a template default.
- Product-specific roles, RLS policies, and RPC boundaries belong in later migrations after the app data model is defined.
