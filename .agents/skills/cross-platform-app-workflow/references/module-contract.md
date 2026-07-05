# Module Contract

Each functional module should own:

```text
src/modules/<module>/
  components/
  hooks/
  routes/
  schemas/
  services/
  state/
  tests/
  index.ts
```

Rules:

- Export public module APIs from `index.ts`.
- Avoid cross-module deep relative imports.
- Keep data schemas close to module behavior.
- Keep reusable generic helpers in `src/lib`.
- Add tests proportional to module risk and shared surface area.
