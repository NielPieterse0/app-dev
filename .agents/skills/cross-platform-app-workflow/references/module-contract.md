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
- Import other modules only through their public `index.ts` surface.
- In the React/Vite/Capacitor template, use `@/modules/<module>` for cross-module imports. Deep imports into another module's internals are lint errors.
- Keep data schemas close to module behavior.
- Keep reusable generic helpers in `src/lib`.
- Add tests proportional to module risk and shared surface area.
