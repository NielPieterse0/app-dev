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
    {
      name: "desktop-1440",
      use: {
        ...devices["Desktop Chrome"],
        viewport: { width: 1440, height: 900 },
      },
    },
    {
      name: "laptop-1280",
      use: {
        ...devices["Desktop Chrome"],
        viewport: { width: 1280, height: 800 },
      },
    },
    {
      name: "tablet-768",
      use: {
        ...devices["iPad (gen 7)"],
        viewport: { width: 768, height: 1024 },
      },
    },
    {
      name: "mobile-390",
      use: {
        ...devices["iPhone 12"],
        viewport: { width: 390, height: 844 },
      },
    },
  ],
});
