# Testing And Verification Standard

## Required Checks

Use the package manager and scripts already present in each app.

```text
typecheck
lint
test
build
e2e
```

If a script is missing, report it. Do not claim it passed.

## Rendered UI Checks

For UI work, builds are not enough. Verify the rendered app:

- App loads to a meaningful screen.
- No framework error overlay appears.
- Console has no relevant errors.
- Core user interaction changes UI state.
- Desktop and mobile viewport layouts work.
- Text and controls do not overlap or clip.

Use the Browser plugin when available. Use Playwright as fallback.

## App Store Wrapper Checks

For Capacitor projects, verify web build first, then native wrapper configuration. Native emulator/device checks should be scoped to the feature requiring native behavior.
