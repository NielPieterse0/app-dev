import { expect, test } from "@playwright/test";

test("loads the signal dashboard across required responsive widths", async ({ page }) => {
  await page.addInitScript(() => {
    localStorage.setItem(
      "signal.source-feed",
      JSON.stringify({
        items: [
          {
            id: "github:react",
            source: "github",
            externalId: "react",
            title: "facebook/react",
            summary: "A strong frontend signal with reusable compiler and runtime implications.",
            url: "https://github.com/facebook/react",
            author: "facebook",
            publishedAt: "2026-07-09T08:00:00.000Z",
            collectedAt: "2026-07-09T09:00:00.000Z",
            engagementCount: 320,
            score: 22.4,
            keywords: ["react", "compiler", "frontend"],
          },
        ],
        lastRefreshedAt: "2026-07-09T09:00:00.000Z",
      })
    );
  });

  await page.goto("/");

  await expect(page.getByRole("heading", { name: "Trend scout" })).toBeVisible();
  await expect(page.getByRole("navigation", { name: "Primary" })).toBeVisible();
  await expect(page.getByRole("button", { name: "Refresh live feed" })).toBeVisible();
  await expect(page.getByRole("link", { name: "facebook/react" })).toBeVisible();
  await expect(page.getByRole("button", { name: "GitHub" })).toBeVisible();
  await page.getByRole("button", { name: "Inspect" }).click();
  await expect(page.getByText("Promote to concept")).toBeVisible();
  await page.getByRole("button", { name: "Promote to concept" }).click();
  await expect(page.getByRole("heading", { name: "Concept workbench" })).toBeVisible();
  await expect(page.getByRole("button", { name: "Copy Markdown" })).toBeVisible();

  await page.getByRole("link", { name: "Settings" }).click();
  await expect(page.getByRole("heading", { name: "Signal settings" })).toBeVisible();
  await expect(page.getByRole("link", { name: "Keywords" })).toBeVisible();
  await expect(page.getByRole("button", { name: "Enabled GitHub" })).toBeVisible();
  await page.getByRole("button", { name: "Save source settings" }).click();
  await expect(
    page.getByText(
      /(Saved locally while the configured remote workspace is unavailable|Settings saved in the configured remote workspace)/i
    )
  ).toBeVisible();

  await page.getByRole("link", { name: "Keywords" }).click();
  await expect(page.getByRole("heading", { name: "Keyword pressure" })).toBeVisible();
  await expect(page.getByRole("textbox", { name: "Keyword filters" })).toBeVisible();
  await page.getByRole("textbox", { name: "Keyword filters" }).fill("agents, workflow");
  await page.getByRole("button", { name: "Save keyword settings" }).click();
  await expect(
    page.getByText(
      /(Saved locally while the configured remote workspace is unavailable|Settings saved in the configured remote workspace)/i
    )
  ).toBeVisible();

  const hasHorizontalOverflow = await page.evaluate(() => {
    const { documentElement } = document;
    return documentElement.scrollWidth > documentElement.clientWidth;
  });

  expect(hasHorizontalOverflow).toBe(false);
});
