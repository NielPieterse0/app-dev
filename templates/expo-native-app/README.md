# Expo Native App Template

Use this template only when native mobile behavior is central and web-first Capacitor is not enough.

Typical reasons: camera-heavy flows, Bluetooth, background tasks, native maps, complex gestures, deep offline mobile behavior, or native navigation expectations.

After creating a project, install dependencies inside the generated project:

```powershell
npm install
npm run typecheck
npm run lint
npm run test
```

This template includes `App.tsx`, `app.json`, TypeScript, ESLint, Jest Expo, and a React Native Testing Library smoke test. Document platform permissions in `AGENTS.md` before adding device APIs such as camera, contacts, location, Bluetooth, background tasks, or secure storage.
