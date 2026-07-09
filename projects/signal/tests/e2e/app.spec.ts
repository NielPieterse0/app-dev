import { expect, test } from "@playwright/test";

test("loads the signal dashboard across required responsive widths", async ({ page }) => {
  await page.goto("/");

  await expect(page.getByRole("heading", { name: "Trend scout" })).toBeVisible();
  await expect(page.getByRole("navigation", { name: "Primary" })).toBeVisible();
  await expect(page.getByRole("button", { name: "Refresh live feed" })).toBeVisible();
  await expect(page.getByText("No persisted signals yet")).toBeVisible();
  await expect(page.getByRole("button", { name: "GitHub" })).toBeVisible();

  await page.getByRole("link", { name: "Settings" }).click();
  await expect(page.getByRole("heading", { name: "Signal settings" })).toBeVisible();
  await expect(page.getByRole("link", { name: "Keywords" })).toBeVisible();
  await expect(page.getByRole("button", { name: "Enabled GitHub" })).toBeVisible();
  await page.getByRole("button", { name: "Save source settings" }).click();
  await expect(
    page.getByText(/(Saved locally while Supabase is unavailable|Settings saved to Supabase)/i)
  ).toBeVisible();

  await page.getByRole("link", { name: "Keywords" }).click();
  await expect(page.getByRole("heading", { name: "Keyword pressure" })).toBeVisible();
  await expect(page.getByRole("textbox", { name: "Keyword filters" })).toBeVisible();
  await page.getByRole("textbox", { name: "Keyword filters" }).fill("agents, workflow");
  await page.getByRole("button", { name: "Save keyword settings" }).click();
  await expect(
    page.getByText(/(Saved locally while Supabase is unavailable|Settings saved to Supabase)/i)
  ).toBeVisible();

  const hasHorizontalOverflow = await page.evaluate(() => {
    const { documentElement } = document;
    return documentElement.scrollWidth > documentElement.clientWidth;
  });

  expect(hasHorizontalOverflow).toBe(false);
});
