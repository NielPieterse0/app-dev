import { defineConfig, devices } from "@playwright/test";

const webServerEnv = { ...process.env };
delete webServerEnv.FORCE_COLOR;

export default defineConfig({
  testDir: "./tests/e2e",
  webServer: {
    command: "npm run dev -- --host 127.0.0.1",
    env: webServerEnv,
    url: "http://127.0.0.1:5173",
    reuseExistingServer: !process.env.CI,
  },
  use: {
    baseURL: "http://127.0.0.1:5173",
    trace: "on-first-retry",
  },
  projects: [
    { name: "desktop", use: { ...devices["Desktop Chrome"] } },
    { name: "mobile", use: { ...devices["Pixel 5"] } },
  ],
});
